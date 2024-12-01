import { useState } from "react";
import NfidLogin from "./components/NfidLogin";
import SentimentAnalysis from "./components/SentimentAnalysis";
import UserResults from "./components/UserResults";
import "./App.css";

function App() {
  const [backendActor, setBackendActor] = useState(null);
  const [userId, setUserId] = useState(null);
  const [userName, setUserName] = useState(null);

  const handleSubmitUserProfile = async (event) => {
    event.preventDefault();
    const name = event.target.elements.name.value;

    try {
      const response = await backendActor.setUserProfile(name);
      if (response.ok) {
        setUserId(response.ok.id.toString());
        setUserName(response.ok.name);
      } else if (response.err) {
        setUserId(response.err);
      }
    } catch (error) {
      console.error("Error setting user profile:", error);
      setUserId("Unexpected error, check the console");
    }
  };

  return (
    <main className="centered-container">
      <img src="/logo2.svg" alt="DFINITY logo" />
      <h1>Welcome to IC AI Hacker House!</h1>

      {!backendActor ? (
        <section id="nfid-section">
          <NfidLogin setBackendActor={setBackendActor} />
        </section>
      ) : (
        <>
          <form onSubmit={handleSubmitUserProfile}>
            <label htmlFor="name">Enter your name: &nbsp;</label>
            <input id="name" type="text" />
            <button type="submit">Save</button>
          </form>

          {userId && <section className="response">User ID: {userId}</section>}
          {userName && (
            <section className="response">User Name: {userName}</section>
          )}

          <SentimentAnalysis backendActor={backendActor} />
          <UserResults backendActor={backendActor} />
        </>
      )}
    </main>
  );
}

export default App;
