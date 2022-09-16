# Stanford Encyclopedia of Philosophy Reader App

## Description

This is an app for reading the [Stanford Encyclopedia of Philosophy](https://en.wikipedia.org/wiki/Stanford_Encyclopedia_of_Philosophy). It is a Flutter app. It delivers a new entry from the encyclopedia everyday. The app uses GPT-3 to also generate custom questions based on the entry to solidify understanding. Optionally, you can also export the questions to an Anki deck.

## Flutter App Functionality

- Displays the bionic text
- Sends preamble through BART (HuggingFace) to generate summary
- Sends summarized preamble through GPT-3 to generate questions baseed on the article
- Fetches new article on-demand

### Tech Stack

Figma, Flutter + Dart, RapidAPI, OpenAI GPT3, HuggingFace

[Random SEP Entry](https://plato.stanford.edu/cgi-bin/encyclopedia/random)
