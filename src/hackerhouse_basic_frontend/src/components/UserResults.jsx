import { useState, useEffect } from "react";

function UserResults({ backendActor }) {
  const [results, setResults] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchUserResults() {
      try {
        const response = await backendActor.getUserResults();
        if (response.ok) {
          setResults(response.ok.results);
          setError(null); // Clear any previous error
        } else {
          setError("Failed to load results.");
        }
      } catch (error) {
        console.error("Error fetching user results:", error);
        setError("Failed to load results."); // Set a user-friendly error message
      }
    }

    fetchUserResults();
  }, [backendActor]);

  return (
    <div>
      <h2>User Results</h2>
      {error ? (
        <p style={{ color: "red" }}>{error}</p>
      ) : results.length > 0 ? (
        <ul>
          {results.map((result, index) => (
            <li key={index}>{result}</li>
          ))}
        </ul>
      ) : (
        <p>No results found.</p>
      )}
    </div>
  );
}

export default UserResults;
