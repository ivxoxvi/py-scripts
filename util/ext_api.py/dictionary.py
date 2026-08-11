# https://github.com/meetDeveloper/freeDictionaryAPI

import requests


def word_definition(word: str):
    url = f"https://api.dictionaryapi.dev/api/v2/entries/en/{word}"
    response = requests.get(url, timeout=30)
    return response.json()


if __name__ == "__main__":
    print(word_definition("fuck"))
