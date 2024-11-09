# Basic and Intermediate Challenge for ICP AI HackerHouse

Welcome to this tutorial that is for people to get started into ICP, a decentralized cloud built on blockchain technology. Architected for being general purpose, the only limit you have is your imagination. 🙂🚀

On this challenge, the main goals are:

- to introduce to IC, showcasing great examples of what is already possible
- to help you getting started in a quick but still effective way
- to hopefully convince you the IC stack and ecosystem is a great place to have a Dev career or co-found a startup.

## Challenge Overview

This challenge will be in Motoko. We have prepared a Codespace for you, so you don't waste time on local setup and can go directly to the fun part, coding! ⌨️

In the basic challenge you will:
- Develop a canister (backend) that logs in with Gmail, with an ICP wallet provider called NFID.
- Work on the backend, understanding data structures, packages, stable/dynamic memory, etc.
- You will allow to setup a user profile and safely store user records (like the results of the AI Model).

In the intermediate challenge you will:
- Connect that backend to the API of HuggingFace, using IC HTTP Outcalls.
- We will use a basic one, phrase sentiment analysis model.
- You will need to parse the response and more clearly show the model result.
- Then on the frontend you need to improve it and allow the user to interact with the new AI / API features you just added.

## Submission Details & Requirements

For getting the 50 (only basic) or the 100 (basic + intermediate) ckUSDT prize, you will need to:
- Join the Taikai platform (where we publickly handle all the submissions): https://taikai.network/icp-portugal/hackathons/ICP-AI-HACKERHOUSE
- Create a project, following the instructions on the video, namely:
  - Title saying "Easy Challenge - Your Name" or "Intermediate Challenge" if it's the case.
  - Add your github that allows to see the code finishing the challenge.
  - A video recording of the Candid UI (Basic Challenge) or the Frontend (Intermediate Challenge) showing the dApp behaving as expected on the challenge.

## Tutorial Videos

Tutorial Videos explaining and walking through each of the methods / behaviour expected. 
Note: Feel free to listen at 1.2x speed 😛

IC Overview (recorded on a recent workshop with CS Students):
- https://www.youtube.com/watch?v=wyHAh9i1cFI

Challenge Overview and Submission Instructions 
- https://www.loom.com/share/183cb33b30e34bf5a093ca5eaf9c9c16

Basic:
- Github and Codespace setup
- Overview of code structure
  -   https://www.loom.com/share/b7889a4beb2d4136acc89213756c0c82
- Login and user registration / update
  - (part 1) https://www.loom.com/share/ed875f6b86ae41c492ee6b0fe721b402
  - (part 2) https://www.loom.com/share/1bee546548d948f591bfc11de2066359
- Store more complex data, like previous model results associated with an User.
  - https://www.loom.com/share/1e7790892d2a459f9193b8ca30074bf6

Intermediate:
- HTTP Outcall and Hugging Face API overview
- Call and parse the data, and select best result
- Render and improve frontend to enable user to better interact with the features you built.
  - https://www.loom.com/share/ee46c7c0daf44bc39030fc5ba560c50f   



# General Instructions / Commands

If you want to start working on your project right away, you might want to try the following commands:

## Running the project locally

If you want to test your project locally, you can use the following commands:

```bash
# On a new tab start the replica, it will be important for logs
dfx start

# On previous tab, deploy your canisters to the replica and generate your candid interface
dfx deploy

# For getting the right Codespace links, you can run this script
./scripts/canister_urls.py
```

Once the job completes, your application will be available at the links provided (be aware of copying the query params to the Codespace machine url!).

If you are making frontend changes, you can start a development server with

```bash
npm start
```

Which will start a server at `http://localhost:3000`, proxying API requests to the replica at port 4943.
