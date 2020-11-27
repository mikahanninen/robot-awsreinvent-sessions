*** Settings ***
Library           RPA.FileSystem
Library           RPA.Browser
Library           RPA.Robocloud.Secrets
Library           parsecontent.py
Task Teardown     Close All Browsers

*** Variables ***
${MY_SECRET_KEY}    aws-reinvent
${AWS_REINVENT_SITE}    https://reinvent.awsevents.com/
${AWS_SESSIONS_HTML}    aws_sessions.html
${SESSIONS_CSV}    sessions.csv
${SEPARATOR}      --------------------------------------------------------------------
@{LANGUAGE_FILTER}    spanish    chinese    korean    italian    portuguese    japanese

*** Keywords ***
Init Variables
    ${SESSION_STATS}=    Evaluate    os.getenv('AWS_SESSION_STATS', False)
    ${DATE}=    Evaluate    os.getenv('AWS_SESSION_DATE', "")
    ${TAG}=    Evaluate    os.getenv('AWS_SESSION_TAG', "")
    ${AWS_DESC}=    Evaluate    os.getenv('AWS_SESSION_DESC', False)
    Set Suite Variable    ${SESSION_STATS}
    Set Suite Variable    ${DATE}
    Set Suite Variable    ${TAG}
    Set Suite Variable    ${AWS_DESC}

*** Keywords ***
Get Session List From Web
    ${secrets}=    Get Secret    ${MY_SECRET_KEY}
    Open Available Browser    ${AWS_REINVENT_SITE}
    # Accept cookie consent if required
    Run Keyword And Ignore Error    Click Element    //button[@data-id='awsccc-cb-btn-accept']
    Log In To View Session Catalog
    Wait Until Element Is Visible    //a[text()="View Sessions"]    timeout=15s
    Click Element    //a[text()="View Sessions"]
    # There are lot sessions and we need to get them visible into dom
    Run Keyword And Ignore Error    Repeat Keyword    500 times    Click Element When Visible    //button[@class='btn-view-later']
    ${content}=    Get Source
    Create File    ${AWS_SESSIONS_HTML}    ${content}

*** Keywords ***
Log In To View Session Catalog
    Click Element When Visible    //a[@title='Log In to View Session Catalog']
    # New TAB was opened
    Switch Window    NEW
    Wait Until Element Is Visible    //input[@name="email"]    timeout=15s
    Input Password    //input[@name="email"]    ${secrets}[email]
    Input Password    //input[@name="password"]    ${secrets}[password]
    Click Element    //button[text()="Sign In"]

*** Tasks ***
Get AWS session list
    Init Variables
    ${exists}=    Does File Exist    ${AWS_SESSIONS_HTML}
    Run Keyword Unless    ${exists}    Get Session List From Web
    ${rows}    ${tagcloud}=    Filter Data By Command Line Argument    ${AWS_SESSIONS_HTML}    ${TAG}    ${DATE}
    Log To Console    ${EMPTY}
    FOR    ${row}    IN    @{rows}
        Log To Console    ${SEPARATOR}
        ${details}=    Set Variable If    ${AWS_DESC}    ${row}[description]
        Log To Console    ${row}[schedule] - ${row}[name]
        Run Keyword If    ${AWS_DESC}    Log To Console    ${details}
    END
    Log To Console    ${SEPARATOR}\nTag Statistics\n${SEPARATOR}
    Run Keyword If    ${SESSION_STATS}    Print Tag Statistics    ${tagcloud}
