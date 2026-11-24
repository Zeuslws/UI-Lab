# ITCS386 UI Lab

Selected tools: **Part 3 - Robot Framework** and **Part 4 - Cypress**.

Compatibility update: Cypress is now pinned to **16.3.0**, because the handout's 16.2.1 crashes on the second spec with Chrome 158 (`* is not a valid URL`). After the interrupted run, use `powershell -ExecutionPolicy Bypass -File .\Resume-Cypress.ps1` to upgrade and collect two full Cypress runs without repeating Robot. See the [official error documentation](https://docs.cypress.io/app/references/error-messages).

**Status: both Robot QP-01 runs and both full Cypress runs passed. Manual QP-01 and the four required QuickPizza CSS locator-count checks are complete. GitHub publication and MyCourses submission remain pending.** Read [RESULTS.md](RESULTS.md) for the exact status. No sample measurements are presented as real results.

## Windows setup

Python 3.10+ and Google Chrome are required. From this folder in a normal PowerShell terminal with internet access, run:

```powershell
.\Setup.ps1
.\Run-Lab.ps1
```

Setup creates a Python virtual environment, installs the pinned Robot packages and Cypress 16.3.0, downloads a matching ChromeDriver outside the repository, and sets CHROMEDRIVER. If npm is absent, it installs a portable Node 24 distribution under your local application-data folder. Run-Lab performs the deliberate wrong-title failures, restores the correct assertions, runs both QP-01 implementations twice, and saves genuine logs, screenshots and Cypress videos. It stops on unexpected failure. It never clears shared ratings.

If PowerShell blocks these local scripts, use `powershell -ExecutionPolicy Bypass -File .\Setup.ps1` and then the same command with `Run-Lab.ps1`. This applies to that process only. Package versions follow the supplied handout; if a registry cannot resolve them, retain that error and verify the required version with the instructor rather than silently changing versions.

## Tool folders and commands

`robot/` contains the first title test, web-form test, QP-01 scenario, and shared QuickPizza keywords in `resources/quickpizza.resource`. From `robot/`, run all three tests with:

```powershell
.\.venv\Scripts\python.exe -m robot -d results/all -v BROWSER:headlesschrome first.robot web_form.robot pizza_scenario.robot
```

`cypress/` contains two browser specs, a reusable admin-login command, and screenshot/video configuration. From `cypress/`, run both specs with:

```powershell
npm.cmd test
```

Robot's required QP-01 reports go into `robot/results/run1` and `run2`. Cypress keeps the latest screenshots/videos under `cypress/cypress/`; the runner archives both full runs under `evidence/<timestamp>/`. API observations and machine-readable run results go into `cypress/reports/`.

## Before submission

1. Move this folder outside Google Drive if it is synchronized; the handout requests a non-cloud-synced working folder.
2. Manual QP-01 and QuickPizza CSS locator-count results are recorded in RESULTS.md.
3. Automated results and reflection are filled in RESULTS.md from the saved evidence. Review RESULTS.md and retain the manual screenshots alongside the automated evidence.
4. Ensure `cypress/package-lock.json` exists after npm installation and include the successful evidence folders.
5. Create a **public** GitHub repository named `ui-lab`, push this folder, and submit its URL on MyCourses. Neither remote publication nor MyCourses submission has been performed.

Do not upload `.venv`, `node_modules`, drivers or real account credentials. The `admin/admin` credentials here are the public demo credentials explicitly supplied in the lab.
