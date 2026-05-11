import asyncio
import os
import re

import pandas as pd

from playwright.async_api import async_playwright


async def scrape_weather(city, month,  day):
    async with async_playwright() as p:
        try:
            browser = await p.chromium.launch(
                headless=True
            )
            context = await browser.new_context(
            )
            page = await context.new_page()

            await page.goto(f"https://yandex.ru/pogoda/ru/{city}/date/{month}/{day}")


            description = await page.text_content('h1 + p')
            
            if not description:
                desc_elem = await page.query_selector('section[class*="heading"] p')
                if desc_elem:
                    description = await desc_elem.text_content()

            if description:
                clean_desc = " ".join(description.split())
                await browser.close()
                return clean_desc
            else:
                print("Описание не найдено. Делаю скриншот для проверки...")
                await page.screenshot(path="debug_no_desc.png")
                await browser.close()
                return None
        except Exception as e:
            print(e)

def main():
    city = "moscow"
    month = "july"
    data = "13"
    descr = asyncio.run(scrape_weather(city, month, data))
    print(descr)

if __name__ == "__main__":
    main()