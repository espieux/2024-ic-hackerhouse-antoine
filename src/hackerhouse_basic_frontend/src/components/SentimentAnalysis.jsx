import { useState } from "react";

function SentimentAnalysis({ backendActor }) {
  const [inputText, setInputText] = useState("");
  const [analysisResult, setAnalysisResult] = useState(null);
  const [errorMessage, setErrorMessage] = useState(null);

  async function handleAnalyze() {
    try {
      const response =
        await backendActor.outcall_ai_model_for_sentiment_analysis(inputText);
      if (response.ok) {
        setAnalysisResult({
          paragraph: response.ok.paragraph,
          sentiment: response.ok.result,
          confidence: response.ok.confidence,
        });
        setErrorMessage(null); // Clear any previous error
      } else {
        setErrorMessage("Failed to analyze sentiment. Please try again later.");
      }
    } catch (error) {
      console.error("Error analyzing sentiment:", error);
      setErrorMessage("Failed to analyze sentiment. Please try again later."); // Set a user-friendly error message
    }
  }

  return (
    <div>
      <h2>Sentiment Analysis</h2>
      <textarea
        value={inputText}
        onChange={(e) => setInputText(e.target.value)}
        placeholder="Enter text to analyze..."
      />
      <button onClick={handleAnalyze}>Analyze Sentiment</button>

      <section>
        {analysisResult && (
          <div>
            <p>
              <strong>Text:</strong> {analysisResult.paragraph}
            </p>
            <p>
              <strong>Sentiment:</strong> {analysisResult.sentiment}
            </p>
            <p>
              <strong>Confidence:</strong>{" "}
              {analysisResult.confidence.toFixed(2)}
            </p>
          </div>
        )}
        {errorMessage && <p style={{ color: "red" }}>{errorMessage}</p>}
      </section>
    </div>
  );
}

export default SentimentAnalysis;
