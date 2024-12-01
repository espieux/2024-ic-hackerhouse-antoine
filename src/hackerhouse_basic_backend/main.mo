// import the custom types we have in Types.mo
import Types "types";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Map "mo:map/Map";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Float "mo:base/Float";
import { phash; nhash} "mo:map/Map";
import Vector "mo:vector";
import { JSON } "mo:serde";

actor {
    stable var autoIndex = 0;
    let userIdMap = Map.new<Principal, Nat>();
    let userProfileMap = Map.new<Nat, Text>();
    let userResultsMap = Map.new<Nat, Vector.Vector<Text>>();

    public query ({ caller }) func getUserProfile() : async Result.Result<{ id : Nat; name : Text }, Text> {
        Debug.print("Principal: " # debug_show caller);
        return #ok({ id = 123; name = "test" });
    };

    public shared ({ caller }) func setUserProfile(name : Text) : async Result.Result<{ id : Nat; name : Text }, Text> {
        // Check if the user is already registered
        switch (Map.get(userIdMap, phash, caller)) {
            case (?caller) {};
            case (_) {
                // Set the new user Id
                Map.set(userIdMap, phash, caller, autoIndex);

                // Set the new user profile name
                Map.set(userProfileMap, nhash, autoIndex, name);

                // Increment the autoIndex
                autoIndex += 1;
            };
        };

        // Search for existing user ID
        let foundId = switch( Map.get(userIdMap, phash, caller)){
            case (?id) id;
            case (_) { return #err ("User ID not found") };
        };

        // Set the existing user profile name
        Map.set(userProfileMap, nhash, foundId, name);

        return #ok({ id = foundId; name = name });
    };

    public shared ({ caller }) func addUserResult(result : Text) : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        // Check if the user is already registered
        let userId = switch (Map.get(userIdMap, phash, caller)) {
            case (?caller) caller;
            case (_) { return #err ("User not found") };
        };

        // Check if the user has results
        let userResults = switch (Map.get(userResultsMap, nhash, userId)) {
            case (?results) results;
            case (_) { Vector.new<Text>() };
        };

        // Add the new result
        Vector.add(userResults, result);
        Map.set(userResultsMap, nhash, userId, userResults);

        return #ok({ id = userId; results = Vector.toArray(userResults) });
    };

    public query ({ caller }) func getUserResults() : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        // Check if the user is already registered
        let userId = switch (Map.get(userIdMap, phash, caller)) {
            case (?caller) caller;
            case (_) { return #err ("User not found") };
        };

        // Check if the user has results
        let userResults = switch (Map.get(userResultsMap, nhash, userId)) {
            case (?results) results;
            case (_) { return #err ("User Results not found") };
        };

        return #ok({ id = userId; results = Vector.toArray(userResults) });
    };

    public func outcall_ai_model_for_sentiment_analysis(paragraph : Text) : async Result.Result<{ paragraph : Text; result : Text; confidence : Float }, Text> {
        let host = "api-inference.huggingface.co";
        let path = "/models/cardiffnlp/twitter-roberta-base-sentiment-latest";

        let headers = [
            {
                name = "Authorization";
                value = "Bearer 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";
            },
            { name = "Content-Type"; value = "application/json" },
        ];

        let body_json : Text = "{ \"inputs\" : \" " # paragraph # "\" }";

        let text_response = await make_post_http_outcall(host, path, headers, body_json);

        // TODO
        // Install "serde" package and parse JSON
        let blob = switch (JSON.fromText(text_response, null)) {
            case (#ok(b)) {b};
            case (_) { return #err("Failed to parse JSON" # text_response) };
        };

        let results: ?[[{label_ : Text; score: Float}]] = from_candid(blob);

        let parsed_results = switch (results) {
            case (?r) { r[0]};
            case (_) { return #err("Failed to parse JSON" # text_response) };
        };

        // Return result
        return #ok({
            paragraph = paragraph;
            result = parsed_results[0].label_;
            confidence = parsed_results[0].score;
        });
    };

    // NOTE: don't edit below this line

    // Function to transform the HTTP response
    // This function can't be private because it's shared with the IC management canister
    // but it's usage, is not meant to be exposed to the frontend
    public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
        let transformed : Types.CanisterHttpResponsePayload = {
            status = raw.response.status;
            body = raw.response.body;
            headers = [
                {
                    name = "Content-Security-Policy";
                    value = "default-src 'self'";
                },
                { name = "Referrer-Policy"; value = "strict-origin" },
                { name = "Permissions-Policy"; value = "geolocation=(self)" },
                {
                    name = "Strict-Transport-Security";
                    value = "max-age=63072000";
                },
                { name = "X-Frame-Options"; value = "DENY" },
                { name = "X-Content-Type-Options"; value = "nosniff" },
            ];
        };
        transformed;
    };

    func make_post_http_outcall(host : Text, path : Text, headers : [Types.HttpHeader], body_json : Text) : async Text {
        //1. DECLARE IC MANAGEMENT CANISTER
        //We need this so we can use it to make the HTTP request
        let ic : Types.IC = actor ("aaaaa-aa");

        //2. SETUP ARGUMENTS FOR HTTP GET request
        // 2.1 Setup the URL and its query parameters
        let url = "https://" # host # path;

        // 2.2 prepare headers for the system http_request call
        let request_headers = [
            { name = "Host"; value = host # ":443" },
            { name = "User-Agent"; value = "hackerhouse_canister" },
        ];

        let merged_headers = Array.flatten<Types.HttpHeader>([request_headers, headers]);

        // 2.2.1 Transform context
        let transform_context : Types.TransformContext = {
            function = transform;
            context = Blob.fromArray([]);
        };

        // The request body is an array of [Nat8] (see Types.mo) so do the following:
        // 1. Write a JSON string
        // 2. Convert ?Text optional into a Blob, which is an intermediate representation before you cast it as an array of [Nat8]
        // 3. Convert the Blob into an array [Nat8]
        let request_body_as_Blob : Blob = Text.encodeUtf8(body_json);
        let request_body_as_nat8 : [Nat8] = Blob.toArray(request_body_as_Blob);

        // 2.3 The HTTP request
        let http_request : Types.HttpRequestArgs = {
            url = url;
            max_response_bytes = null; //optional for request
            headers = merged_headers;
            // note: type of `body` is ?[Nat8] so it is passed here as "?request_body_as_nat8" instead of "request_body_as_nat8"
            body = ?request_body_as_nat8;
            method = #post;
            transform = ?transform_context;
        };

        //3. ADD CYCLES TO PAY FOR HTTP REQUEST

        //The IC specification spec says, "Cycles to pay for the call must be explicitly transferred with the call"
        //IC management canister will make the HTTP request so it needs cycles
        //See: https://internetcomputer.org/docs/current/motoko/main/cycles

        //The way Cycles.add() works is that it adds those cycles to the next asynchronous call
        //"Function add(amount) indicates the additional amount of cycles to be transferred in the next remote call"
        //See: https://internetcomputer.org/docs/current/references/ic-interface-spec/#ic-http_request
        Cycles.add<system>(230_949_972_000);

        //4. MAKE HTTPS REQUEST AND WAIT FOR RESPONSE
        //Since the cycles were added above, we can just call the IC management canister with HTTPS outcalls below
        let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);

        //5. DECODE THE RESPONSE

        //As per the type declarations in `src/Types.mo`, the BODY in the HTTP response
        //comes back as [Nat8s] (e.g. [2, 5, 12, 11, 23]). Type signature:

        //public type HttpResponsePayload = {
        //     status : Nat;
        //     headers : [HttpHeader];
        //     body : [Nat8];
        // };

        //We need to decode that [Nat8] array that is the body into readable text.
        //To do this, we:
        //  1. Convert the [Nat8] into a Blob
        //  2. Use Blob.decodeUtf8() method to convert the Blob to a ?Text optional
        //  3. We use a switch to explicitly call out both cases of decoding the Blob into ?Text
        let response_body : Blob = Blob.fromArray(http_response.body);
        let decoded_text : Text = switch (Text.decodeUtf8(response_body)) {
            case (null) { "No value returned" };
            case (?y) { y };
        };

        // 6. RETURN RESPONSE OF THE BODY
        return decoded_text;
    };
};
