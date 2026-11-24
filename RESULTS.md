# UI lab results

Tool parts that I chose: Part 3 (Robot Framework) and Part 4 (Cypress).

## Execution status

**NOT READY FOR SUBMISSION.** Source code is prepared from the supplied W12 handout. No browser tests have run in this session, so pass results, durations, pizza observations, screenshots and videos are not available. Package download was blocked by Windows socket permissions (WinError 10013). Robot Framework, SeleniumLibrary and Selenium were absent from the checked Python environments; npm was not on PATH and the checked Cypress cache was absent. These are environment blockers, not observed failures of QuickPizza.

## Part 0

### Local preparation checks

- JavaScript syntax checks (`node --check`): passed for all five JavaScript files.
- PowerShell parser checks: passed for Setup.ps1 and Run-Lab.ps1.
- Git whitespace validation (`git diff --cached --check`): passed.
- Python virtual environment: created at `robot/.venv` (ignored by Git).
- Attempted installation: `.venv\Scripts\python.exe -m pip install --retries 0 --timeout 5 -r requirements.txt` failed with `No matching distribution found for robotframework==7.5.1` and `from versions: none`. This restricted session cannot establish whether the pinned version is available on the public registry; an earlier pip attempt explicitly reported WinError 10013. No package version was silently substituted.
- No Robot syntax/dry-run check was possible without Robot Framework. JavaScript syntax checks do not establish browser-test correctness.

- Step 0.1, Chrome version: **158.0.8127.37**, read from the installed chrome.exe product version (not yet verified in chrome://version).
- Step 0.3, ChromeDriver version: not installed/verified. Setup.ps1 prepares a matching build.
- Step 0.4 locators below are taken from the handout and implemented in code; live uniqueness checks remain pending.

| Element | Locator |
|---|---|
| Pizza, Please! | `button[name="pizza-please"]` |
| Excluded tools | `select` |
| Must be vegetarian | `#default-checkbox` |
| Custom Pizza Name | `input#pizza-name` |
| Max Calories per Slice | `//label[normalize-space()='Max Calories per Slice']/preceding-sibling::input` |

### Step 0.5: QP-01 manual test case

**Title:** A custom pizza reaches the admin list. **Objective:** check request restrictions, login requirement for ratings, and admin visibility. **Preconditions:** QuickPizza is reachable and the browser is logged out. **Data:** unique `Lab Pizza yyyyMMdd-HHmmss`, 600 calories, Knife excluded, vegetarian selected, demo admin/admin. **Observed pizza name, tool, calories:** not run.

| Step | Action/input | Expected result | Actual result | Pass or fail |
|---|---|---|---|---|
| 1 | Open https://quickpizza.grafana.com | Heading: Looking to break out of your pizza routine? | Not run | Not run |
| 2 | Turn on Advanced | Four advanced fields appear | Not run | Not run |
| 3 | Enter 600, exclude Knife, select vegetarian, enter unique name | Fields show all values | Not run | Not run |
| 4 | Click Pizza, Please! | Same pizza name, tool other than Knife, calories <= 600 | Not run | Not run |
| 5 | Click Love it! without login | Please log in first. | Not run | Not run |
| 6 | Open /admin in the same browser; sign in as admin/admin | Latest pizza recommendations appears | Not run | Not run |
| 7 | Find the unique pizza name in the list | Row shows name and the same tool as step 4 | Not run | Not run |

## Part 3: Robot Framework

- `robot --version`: not available; requirements specify 7.5.1 with SeleniumLibrary 6.9.0.
- Step 3.2, actual failure message for wrong title: not run. The runner changes EXPECTED_TITLE to Web Form for one run, then restores Web form using the default variable.
- Step 3.8, run 1 result, elapsed time, pizza name: not run.
- Step 3.8, run 2 result, elapsed time, pizza name: not run.

## Part 4: Cypress

- Available bundled `node --version`: **v24.22.3**.
- `npm --version` and `npx cypress version`: unavailable; setup pending.
- Step 4.3, actual failure message for wrong title: not run. Run-Lab temporarily changes Web form to Web Form and restores the source in a finally block.
- Step 4.6, observed API tool and calories: not run; future observations are saved by the evidence task.
- Step 4.7, observed admin list line: not run; future line is saved by the evidence task.
- Step 4.8, run 1 result, duration, pizza name: not run.
- Step 4.8, run 2 result, duration, pizza name: not run.
- Step 4.9 (optional), second browser: not attempted.

## Part B

Answers 1-3 and 6-7 explain the supplied design. Answers 4-5 are provisional and must be revised with actual run evidence before submission.

1. The handout describes three number inputs sharing the id floating_filled, so the id alone cannot identify the calories field uniquely. Locating the input through its visible label distinguishes it from the other number inputs. Giving the field a unique id such as max-calories-per-slice, and linking the label with a matching for attribute, would allow a shorter stable locator and improve label association. The live count still needs verification in Part 0.

2. Comparing the recommended tool with the admin row is a consistency-based test oracle: two views of the same record must agree. It does not require knowing which allowed tool the server will select in advance. It would catch a fault where the recommendation shows Scissors but the stored record or admin rendering shows Knife. Searching by the unique pizza name ensures that the comparison uses the intended record.

3. Checking that the vegetarian checkbox is selected proves the input state, not that the returned pizza is vegetarian. A further check could inspect every returned ingredient against a trusted list of vegetarian ingredients. This needs ingredient identifiers and reliable dietary classifications, either visible on the page or supplied by an independent reference. Checking the response's vegetarian flag is another useful assertion, but that flag alone cannot independently prove the ingredients are vegetarian.

4. The Robot code explicitly waits for elements, text and page hydration using SeleniumLibrary keywords with a ten-second timeout. The Cypress code uses retrying queries/assertions and waits for the intercepted pizza response. Robot is configured to produce keyword-level HTML logs with screenshots, while Cypress is configured to produce videos and screenshots. Since neither tool has executed here, actual authoring-time comparisons, elapsed times and report readability have not been measured; this comparison must be completed after the runs.

5. The provisional Project 2 choice is Cypress because its request interception checks that the submitted limit is 600 and compares the response with what the page renders. Its configured videos and step screenshots should also make a complete scenario easier to review. These reasons follow from the implementation, not successful execution evidence. The final choice should be confirmed after reviewing both tools' real reports and reliability across two runs.

6. For Robot Framework, change the MAX CALORIES variable in robot/resources/quickpizza.resource when the calories locator changes. Both the visibility check and the input/value checks use that variable. The scenario calls Turn On Advanced and Fill In The Pizza Request without knowing the locator. Therefore the resource file centralizes the repair and the scenario remains unchanged.

7. QP-01 keeps customer creation and admin verification in one Cypress test to preserve browser state. The handout explains that a cookie keeps the browser on the same QuickPizza server, whose admin list contains the created pizza. Starting steps 6 and 7 in a second test would clear cookies under default isolation, could select another server, and would also reset test-scoped aliases such as tool. A missing pizza could then be caused by lost test state rather than a defect in the workflow.
