*** Settings ***
Documentation    Shared QuickPizza locators and QP-01 keywords.
Library    SeleniumLibrary    timeout=10s
Library    String

*** Variables ***
${URL}    https://quickpizza.grafana.com
${BROWSER}    chrome
${HEADING}    Looking to break out of your pizza routine?
${MAX CALORIES}    xpath://label[normalize-space()='Max Calories per Slice']/preceding-sibling::input

*** Keywords ***
Open QuickPizza
    [Documentation]    QP-01 step 1: verify the home heading.
    Open Browser    ${URL}    ${BROWSER}
    ...    service=executable_path=r'%{CHROMEDRIVER}'
    Set Window Size    1280    1600
    Wait Until Element Is Visible    css:h1
    Element Text Should Be    css:h1    ${HEADING}

Turn On Advanced
    [Documentation]    QP-01 step 2: display all four advanced fields.
    Click Element    xpath://label[.//span[normalize-space()='Advanced']]
    Wait Until Element Is Visible    ${MAX CALORIES}
    Element Should Be Visible    css:select
    Element Should Be Visible    id:default-checkbox
    Element Should Be Visible    css:input#pizza-name
    Wait Until Page Contains Element    xpath://select/option[normalize-space()='Knife']

Fill In The Pizza Request
    [Documentation]    QP-01 step 3: fill and assert the restrictions.
    [Arguments]    ${calories}    ${tool}    ${name}
    Input Text    ${MAX CALORIES}    ${calories}
    Select From List By Label    css:select    ${tool}
    Select Checkbox    id:default-checkbox
    Input Text    css:input#pizza-name    ${name}
    Textfield Value Should Be    ${MAX CALORIES}    ${calories}
    List Selection Should Be    css:select    ${tool}
    Checkbox Should Be Selected    id:default-checkbox
    Textfield Value Should Be    css:input#pizza-name    ${name}

Ask For A Pizza
    [Documentation]    QP-01 step 4: request and wait for a recommendation.
    Click Button    name:pizza-please
    Wait Until Element Contains    id:recommendations    Name:

Get Recommended Tool
    ${line}=    Get Text    xpath://*[@id='recommendations']//p[starts-with(.,'Tool:')]
    ${tool}=    Remove String    ${line}    Tool:${SPACE}
    ${tool}=    Strip String    ${tool}
    RETURN    ${tool}

Get Calories Per Slice
    ${line}=    Get Text    xpath://p[starts-with(.,'Calories per slice:')]
    ${calories}=    Remove String    ${line}    Calories per slice:${SPACE}
    ${calories}=    Convert To Number    ${calories}
    RETURN    ${calories}

Recommendation Should Keep The Restrictions
    [Documentation]    QP-01 step 4: assert name, excluded tool and calories.
    [Arguments]    ${name}    ${excluded tool}    ${max calories}
    Element Should Contain    id:recommendations    Name: ${name}
    ${tool}=    Get Recommended Tool
    Should Not Be Empty    ${tool}
    Should Not Be Equal    ${tool}    ${excluded tool}
    ${calories}=    Get Calories Per Slice
    Should Be True    0 <= ${calories} <= ${max calories}
    RETURN    ${tool}

Rate The Pizza Without Logging In
    [Documentation]    QP-01 step 5: anonymous rating requires login.
    Click Button    name:rate-5
    Wait Until Element Contains    id:rate-result    Please log in first.
    Element Text Should Be    id:rate-result    Please log in first.

Log In As Admin
    [Documentation]    QP-01 step 6: wait for hydration and sign in.
    [Arguments]    ${user}    ${password}
    Go To    ${URL}/admin
    Wait Until Page Contains Element    id:svelte-announcer
    Input Text    id:username    ${user}
    Input Password    id:password    ${password}
    Click Button    css:button[type=submit]
    Wait Until Page Contains    Latest pizza recommendations

Admin List Should Show The Pizza
    [Documentation]    QP-01 step 7: search all rows and compare the tool.
    [Arguments]    ${name}    ${tool}
    Wait Until Page Contains Element    xpath://li[contains(.,'${name}')]
    Element Should Contain    xpath://li[contains(.,'${name}')]    (tool=${tool},
