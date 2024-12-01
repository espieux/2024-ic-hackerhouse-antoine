import { useState } from "react";
import { NFID } from "@nfid/embed";
import { HttpAgent } from "@dfinity/agent";
import {
  canisterId,
  createActor,
} from "declarations/hackerhouse_basic_backend";

function NfidLogin({ setBackendActor }) {
  const [principal, setPrincipal] = useState("Not Logged In");

  async function handleLogin() {
    try {
      const nfid = await NFID.init({
        application: {
          name: "IC AI Hacker House",
          logo: "https://taikai.azureedge.net/g85_fmDME2uOKEmFV0CfFmfcZQCmiDvIFknjOsWr8v8/rs:fit:350:0:0/aHR0cHM6Ly9zdG9yYWdlLmdvb2dsZWFwaXMuY29tL3RhaWthaS1zdG9yYWdlL2ltYWdlcy9iYTViMmVhMC04ZDUxLTExZWYtYTI3MS02NTA0MjI1OTI3NGJTcXVlcmUtMiAoMikucG5n",
        },
      });

      const identity = await nfid.getDelegation({
        maxTimeToLive: BigInt(8) * BigInt(3_600_000_000_000),
      });
      const agent = new HttpAgent({ identity });
      if (process.env.DFX_NETWORK === "local") agent.fetchRootKey();

      const backendActor = createActor(canisterId, { agent });
      setBackendActor(backendActor);
      setPrincipal(identity.getPrincipal().toText());
    } catch (error) {
      console.error("Login failed:", error);
    }
  }

  return (
    <div>
      <section>
        <button id="loginBtn" onClick={handleLogin}>
          Login with Gmail (powered by NFID)
        </button>
      </section>
      <section id="loginStatus">
        <p>{principal}</p>
        {principal !== "Not Logged In" && (
          <p>
            <em>Note: Never use this principal for production usage!</em>
          </p>
        )}
      </section>
    </div>
  );
}

export default NfidLogin;
