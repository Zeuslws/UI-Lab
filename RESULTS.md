# UI lab results

Tool parts that I chose: Part 3 (Robot Framework) and Part 4 (Cypress).

## Execution status

Automated testing completed: both Robot QP-01 runs passed, and both full Cypress runs passed (2 tests each). Screenshots, videos and reports are saved. Manual recommendation and admin matching are confirmed from user screenshots. The final named run also shows Please log in first. in the user screenshot, completing manual QP-01. The user verified the four required CSS locators in the browser console: each matched one element; floating_filled matched three. GitHub publication and MyCourses submission remain pending.

Cypress was upgraded from the handout's 16.2.1 to 16.3.0 after Chrome 158 caused `* is not a valid URL` on the second spec. The successful reruns use 16.3.0. The original failure is retained in `evidence/20261125-044806/console.txt`; the successful reruns are in `evidence/20261125-045251-cypress-resume/console.txt`. See https://docs.cypress.io/app/references/error-messages .

## Part 0

- Step 0.1, Chrome version: **158.0.8127.37**, read from the installed chrome.exe product version (not yet verified in chrome://version).
- Step 0.3, ChromeDriver version: **158.0.8127.88**, recorded in the execution transcript.
- Step 0.4: user console screenshot confirms counts of 1 for the pizza button, excluded-tools list, vegetarian checkbox and custom-name input; #floating_filled matches 3 elements. The calories XPath is used successfully by the Robot tests; its separate console check is not recorded.

| Element | Locator |
|---|---|
| Pizza, Please! | `button[name="pizza-please"]` |
| Excluded tools | `select` |
| Must be vegetarian | `#default-checkbox` |
| Custom Pizza Name | `input#pizza-name` |
| Max Calories per Slice | `//label[normalize-space()='Max Calories per Slice']/preceding-sibling::input` |

### Step 0.5: QP-01 manual test case

**Title:** A custom pizza reaches the admin list. **Objective:** check request restrictions, login requirement for ratings, and admin visibility. **Preconditions:** QuickPizza is reachable and the browser is logged out. **Data:** unique `Lab Pizza yyyyMMdd-HHmmss`, 600 calories, Knife excluded, vegetarian selected, demo admin/admin. **Observed pizza name, tool, calories:** `Lab Pizza 25/11 05:03`, **Scissors**, **525 calories per slice**. User screenshots confirm the recommendation and matching admin row. The earlier attempt used `zeuslws 25/11 04:58` (Pizza cutter, 475 calories) and showed the anonymous-rating message; its pizza was not visible in the admin screenshot. The repeat used the required Lab Pizza prefix.

| Step | Action/input | Expected result | Actual result | Pass or fail |
|---|---|---|---|---|
| 1 | Open https://quickpizza.grafana.com | Heading: Looking to break out of your pizza routine? | User reported completing steps 1-5; exact heading is outside screenshot crop | Reported pass |
| 2 | Turn on Advanced | Four advanced fields appear | All four fields visible in screenshot | PASS |
| 3 | Enter 600, exclude Knife, select vegetarian, enter unique name | Fields show all values | 600, Knife selected, vegetarian checked, Lab Pizza 25/11 05:03 | PASS |
| 4 | Click Pizza, Please! | Same pizza name, tool other than Knife, calories <= 600 | Lab Pizza 25/11 05:03; Scissors; 525 <= 600 | PASS |
| 5 | Click Love it! without login | Please log in first. | Please log in first. visible for Lab Pizza 25/11 05:03 in user screenshot | PASS |
| 6 | Open /admin in the same browser; sign in as admin/admin | Latest pizza recommendations appears | Heading and Logout button visible | PASS |
| 7 | Find the unique pizza name in the list | Row shows name and the same tool as step 4 | Lab Pizza 25/11 05:03 (tool=Scissors, ingredients_number=8) | PASS |

## Part 3: Robot Framework

- Version: **Robot Framework 7.5.1 (Python 3.12.1 on win32)**; SeleniumLibrary 6.9.0 is pinned in requirements.
- Step 3.2 intentional failure: `Title should have been 'Web Form' but was 'Web form'.` The restored title and web-form tests subsequently passed (2/2).
- Step 3.8 results below use suite elapsed seconds from each `output.xml`.

| Run | Result | Elapsed | Pizza name | Tool | Calories |
|---|---|---|---|---|---|
| 1 | PASS, 1/1 | 9.075408 s | Lab Pizza 20261125-044836 | Pizza cutter | 500 |
| 2 | PASS, 1/1 | 8.900837 s | Lab Pizza 20261125-044845 | Pizza cutter | 450 |

Evidence: [run 1 report](robot/results/run1/report.html), [run 1 log](robot/results/run1/log.html), [run 2 report](robot/results/run2/report.html), [run 2 log](robot/results/run2/log.html). Each run contains the four required screenshots.

## Part 4: Cypress

- Node: **v24.22.3**; installed npm package: **11.19.1**; successful-run Cypress: **16.3.0**; Chrome: **158.0.8127.37**.
- Step 4.3 intentional failure (16.2.1): `Timed out retrying after 10000ms`, actual `Web form`, expected `Web Form`. The correct title was restored before the full runs.
- Step 4.6 response observations: run 1 returned **Scissors, 350 calories**; run 2 returned **Pizza cutter, 325 calories**. The tests also verified the request limit and the matching rendered values.
- Step 4.7 observed admin rows:
  - `Lab Pizza 20261125-045441 (tool=Scissors, ingredients_number=5) (newest)`
  - `Lab Pizza 20261125-045507 (tool=Pizza cutter, ingredients_number=5)`
- Step 4.8 full-run results (both pizza and web-form specs):

| Run | Result | Total duration | Pizza name |
|---|---|---|---|
| 1 | PASS, 2/2, 0 failed | 12.331 s | Lab Pizza 20261125-045441 |
| 2 | PASS, 2/2, 0 failed | 12.938 s | Lab Pizza 20261125-045507 |

Durations are `totalDuration` from `cypress/reports/20261125-045251-resume-run1/run.json` and `run2/run.json`. They cover both specs, unlike Robot's QP-01-only timings. API and admin observations are in each run's `observations.jsonl`. Both runs' screenshots and videos are archived in `evidence/20261125-045251-cypress-resume/`; latest evidence also remains under `cypress/cypress/screenshots` and `videos`.

- Step 4.9 (optional), second browser: not attempted.

## Part B

The comparison below uses saved execution evidence. Authoring time was not measured.

1. The handout describes three number inputs sharing the id floating_filled, so the id alone cannot identify the calories field uniquely. Locating the input through its visible label distinguishes it from the other number inputs. Giving the field a unique id such as max-calories-per-slice, and linking the label with a matching for attribute, would allow a shorter stable locator and improve label association. The user console check confirmed three matches for floating_filled.

2. Comparing the recommended tool with the admin row is a consistency-based test oracle: two views of the same record must agree. It does not require knowing which allowed tool the server will select in advance. It would catch a fault where the recommendation shows Scissors but the stored record or admin rendering shows Knife. Searching by the unique pizza name ensures that the comparison uses the intended record.

3. Checking that the vegetarian checkbox is selected proves the input state, not that the returned pizza is vegetarian. A further check could inspect every returned ingredient against a trusted list of vegetarian ingredients. This needs ingredient identifiers and reliable dietary classifications, either visible on the page or supplied by an independent reference. Checking the response's vegetarian flag is another useful assertion, but that flag alone cannot independently prove the ingredients are vegetarian.

4. Robot uses explicit ten-second waits for elements and text; Cypress retries queries/assertions and waits for the intercepted pizza response. Robot's QP-01 suites passed in 9.075 and 8.901 seconds, while Cypress's two-spec suites passed in 12.331 and 12.938 seconds, so those timings are not directly comparable. Robot's log organizes the scenario as named keywords with screenshots, while Cypress produced a video for each spec and separate screenshots for steps 4, 5 and 7. The second Cypress admin screenshot clearly shows the target pizza below another user's newer pizza, demonstrating why searching all rows is necessary. Actual authoring time was not recorded; the Robot scenario is concise because its locator details reside in the resource file. Cypress required a version upgrade to resolve the observed Chrome compatibility crash before both full runs passed.

5. I would choose Cypress for Project 2 because the successful runs verified both the submitted calorie limit and agreement between the API response and the displayed tool/calories. It also produced videos for both specs and screenshots of the recommendation, login rejection and admin list. Both complete reruns passed after upgrading to 16.3.0, providing repeatability evidence for this environment. The Chrome 158 failure shows that the project should pin a compatible Cypress version and retain its lockfile.

6. For Robot Framework, change the MAX CALORIES variable in robot/resources/quickpizza.resource when the calories locator changes. Both the visibility check and the input/value checks use that variable. The scenario calls Turn On Advanced and Fill In The Pizza Request without knowing the locator. Therefore the resource file centralizes the repair and the scenario remains unchanged.

7. QP-01 keeps customer creation and admin verification in one Cypress test to preserve browser state. The handout explains that a cookie keeps the browser on the same QuickPizza server, whose admin list contains the created pizza. Starting steps 6 and 7 in a second test would clear cookies under default isolation, could select another server, and would also reset test-scoped aliases such as tool. A missing pizza could then be caused by lost test state rather than a defect in the workflow.
