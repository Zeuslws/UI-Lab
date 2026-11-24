*** Settings ***
Library    SeleniumLibrary
Test Teardown    Close Browser

*** Variables ***
${URL}    https://www.selenium.dev/selenium/web/web-form.html
${BROWSER}    chrome
${EXPECTED_TITLE}    Web form

*** Test Cases ***
The Web Form Opens
    [Documentation]    Open the web form and check its title (Step 3.2).
    Open Browser    ${URL}    ${BROWSER}
    ...    service=executable_path=r'%{CHROMEDRIVER}'
    Title Should Be    ${EXPECTED_TITLE}
