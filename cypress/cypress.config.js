const { defineConfig } = require('cypress')
const fs = require('node:fs')
const path = require('node:path')

module.exports = defineConfig({
  viewportWidth: 1280,
  viewportHeight: 1600,
  defaultCommandTimeout: 10000,
  video: true,
  retries: 0,
  e2e: {
    setupNodeEvents(on, config) {
      const evidenceDir = path.join(__dirname, 'reports', process.env.LAB_RUN || 'latest')
      on('task', {
        evidence(data) {
          fs.mkdirSync(evidenceDir, { recursive: true })
          fs.appendFileSync(path.join(evidenceDir, 'observations.jsonl'), JSON.stringify(data) + '\n')
          return null
        },
      })
      on('after:run', results => {
        fs.mkdirSync(evidenceDir, { recursive: true })
        fs.writeFileSync(path.join(evidenceDir, 'run.json'), JSON.stringify(results, null, 2))
      })
      return config
    },
  },
})
