---
description: Manage and visualize tech stack across projects
tags: [global, productivity, tech-stack, reporting]
---

# Tech Stack - Technology Tracking & Reporting

Track and visualize your tech stack across all projects and personal skill inventory.

## Commands

- `/tech-stack` - Show tech stack overview
- `/tech-stack add` - Add technology to a project
- `/tech-stack update` - Update tech proficiency/usage
- `/tech-stack report` - Generate visual report
- `/tech-stack export` - Export to Excel with charts

---

## Show Tech Stack Overview

Display a quick summary of your tech stack.

**Usage:** `/tech-stack`

**Shows:**
- Technologies used across all projects
- Your current skill levels
- Recently learned tech
- Tech you're actively learning

---

## Add Technology to Project

Add a new technology to the current project's tech stack.

**Usage:** `/tech-stack add`

**Prompts for:**
1. Technology name
2. Category (Frontend/Backend/Database/DevOps/Testing/Tools)
3. How it's being used in this project
4. Your proficiency level (Beginner/Intermediate/Advanced/Expert)

**Example:**

```bash
cd ~/Documents/GitHub/llm-ad-platform-cc
/tech-stack add

# Technology: Prisma
# Category: Database
# Usage: ORM for PostgreSQL
# Proficiency: Intermediate

✅ Added Prisma to llm-ad-platform-cc tech stack
✅ Updated your personal tech inventory
```

---

## Update Tech Proficiency

Update your proficiency level or learning status for a technology.

**Usage:** `/tech-stack update`

**Prompts for:**
1. Technology name (autocomplete from existing)
2. New proficiency level
3. Learning status (Proficient/Learning/Want to Learn)
4. Notes

---

## Generate Tech Stack Report

Create a visual report showing tech usage patterns.

**Usage:** `/tech-stack report`

**Generates:**
- Tech stack by project (matrix view)
- Your skill inventory (proficiency chart)
- Learning roadmap (what you're learning)
- Technology coverage (which projects use what)

**Output:** Markdown report + optional HTML dashboard

---

## Export to Excel

Export tech stack data to Excel with formatting and charts.

**Usage:** `/tech-stack export`

**Creates Excel file with:**
- Sheet 1: Tech by Project (table)
- Sheet 2: Tech by User (skill inventory)
- Sheet 3: Technology Matrix (project × tech grid)
- Sheet 4: Charts & Insights

**Location:** `~/.claude/_fpcg_tags/tech-stack-report.xlsx`

---

## Instructions for Claude

When the user runs a /tech-stack command:

### Base Command: Show Overview

```javascript
// Read both CSV files
const projectStackPath = path.join(os.homedir(), '.claude', '_fpcg_tags', 'tech-stack-by-project.csv');
const userStackPath = path.join(os.homedir(), '.claude', '_fpcg_tags', 'tech-stack-by-user.csv');

const projectStack = parseCSV(fs.readFileSync(projectStackPath, 'utf8'));
const userStack = parseCSV(fs.readFileSync(userStackPath, 'utf8'));

// Display overview
console.log(`
# 🛠️ Tech Stack Overview

## 📊 Technologies in Use
${userStack.filter(t => t['Learning Status'] === 'Proficient').length} Proficient
${userStack.filter(t => t['Learning Status'] === 'Learning').length} Currently Learning
${userStack.filter(t => t['Learning Status'] === 'Want to Learn').length} Want to Learn

## 🎯 By Category
**Frontend:** ${userStack.filter(t => t.Category === 'Frontend').map(t => t.Technology).join(', ')}
**Backend:** ${userStack.filter(t => t.Category === 'Backend').map(t => t.Technology).join(', ')}
**Database:** ${userStack.filter(t => t.Category === 'Database').map(t => t.Technology).join(', ')}
**DevOps:** ${userStack.filter(t => t.Category === 'DevOps').map(t => t.Technology).join(', ')}
**Testing:** ${userStack.filter(t => t.Category === 'Testing').map(t => t.Technology).join(', ')}
**Tools:** ${userStack.filter(t => t.Category === 'Tools').map(t => t.Technology).join(', ')}

## 📈 Currently Learning
${userStack.filter(t => t['Learning Status'] === 'Learning').map(t =>
  `- **${t.Technology}** (${t.Proficiency}) - ${t.Notes}`
).join('\n')}

## 🚀 Recent Activity (Last 7 Days)
${userStack.filter(t => {
  const lastUsed = new Date(t['Last Used']);
  const weekAgo = new Date();
  weekAgo.setDate(weekAgo.getDate() - 7);
  return lastUsed >= weekAgo;
}).map(t => `- ${t.Technology} (${t['Projects Using']})`).join('\n')}

📁 Files:
- Projects: ~/.claude/_fpcg_tags/tech-stack-by-project.csv
- User Skills: ~/.claude/_fpcg_tags/tech-stack-by-user.csv
`);
```

### Add Technology to Project

```javascript
const cwd = process.cwd();
const projectName = path.basename(cwd);

// Prompt for tech details
const tech = await prompt('Technology name: ');
const category = await select('Category:', [
  'Frontend', 'Backend', 'Database', 'DevOps', 'Testing', 'Tools'
]);
const usage = await prompt('How is it used in this project? ');
const proficiency = await select('Your proficiency:', [
  'Beginner', 'Intermediate', 'Advanced', 'Expert'
]);

// Update project CSV
const projectRow = projectStack.find(p => p.Project === projectName);
if (projectRow) {
  // Add to appropriate category column
  const currentTech = projectRow[category] || '';
  projectRow[category] = currentTech ? `${currentTech}, ${tech}` : tech;
  projectRow.Notes = `${projectRow.Notes} | ${tech}: ${usage}`.trim();
} else {
  console.log('⚠️  Project not found in tech stack. Add project first with /tag');
  return;
}

// Update or add to user CSV
let userRow = userStack.find(u => u.Technology === tech);
if (userRow) {
  // Update existing
  const projects = userRow['Projects Using'].split(', ');
  if (!projects.includes(projectName)) {
    projects.push(projectName);
    userRow['Projects Using'] = projects.join(', ');
  }
  userRow['Last Used'] = new Date().toISOString().split('T')[0];
  userRow.Proficiency = proficiency; // Update if improved
} else {
  // Add new tech
  userRow = {
    Technology: tech,
    Category: category,
    Proficiency: proficiency,
    'Projects Using': projectName,
    'Last Used': new Date().toISOString().split('T')[0],
    'Learning Status': proficiency === 'Expert' || proficiency === 'Advanced' ? 'Proficient' : 'Learning',
    Notes: usage
  };
  userStack.push(userRow);
}

// Write back to CSV
fs.writeFileSync(projectStackPath, unparseCSV(projectStack));
fs.writeFileSync(userStackPath, unparseCSV(userStack));

console.log(`✅ Added ${tech} to ${projectName} tech stack`);
console.log(`✅ Updated your personal tech inventory`);
```

### Generate Report

```javascript
// Create markdown report
const report = `
# Tech Stack Report
**Generated:** ${new Date().toLocaleString()}

## Technology Matrix

| Project | Frontend | Backend | Database | DevOps | Testing | Tools |
|---------|----------|---------|----------|--------|---------|-------|
${projectStack.map(p =>
  `| ${p.Project} | ${p.Frontend} | ${p.Backend} | ${p.Database} | ${p.DevOps} | ${p.Testing} | ${p.Tools} |`
).join('\n')}

## Skill Inventory by Category

### Frontend
${userStack.filter(t => t.Category === 'Frontend').map(t =>
  `- **${t.Technology}** (${t.Proficiency}) - Used in: ${t['Projects Using']}`
).join('\n')}

### Backend
${userStack.filter(t => t.Category === 'Backend').map(t =>
  `- **${t.Technology}** (${t.Proficiency}) - Used in: ${t['Projects Using']}`
).join('\n')}

### Database
${userStack.filter(t => t.Category === 'Database').map(t =>
  `- **${t.Technology}** (${t.Proficiency}) - Used in: ${t['Projects Using']}`
).join('\n')}

### DevOps
${userStack.filter(t => t.Category === 'DevOps').map(t =>
  `- **${t.Technology}** (${t.Proficiency}) - Used in: ${t['Projects Using']}`
).join('\n')}

### Testing
${userStack.filter(t => t.Category === 'Testing').map(t =>
  `- **${t.Technology}** (${t.Proficiency}) - Used in: ${t['Projects Using']}`
).join('\n')}

### Tools
${userStack.filter(t => t.Category === 'Tools').map(t =>
  `- **${t.Technology}** (${t.Proficiency}) - Used in: ${t['Projects Using']}`
).join('\n')}

## Learning Roadmap

### Currently Learning
${userStack.filter(t => t['Learning Status'] === 'Learning').map(t =>
  `- **${t.Technology}** (Current: ${t.Proficiency}) - ${t.Notes}`
).join('\n')}

### Want to Learn
${userStack.filter(t => t['Learning Status'] === 'Want to Learn').map(t =>
  `- **${t.Technology}** - ${t.Notes}`
).join('\n')}

## Technology Coverage

${(() => {
  const allTechs = [...new Set(userStack.map(t => t.Technology))];
  return allTechs.map(tech => {
    const row = userStack.find(t => t.Technology === tech);
    const projects = row['Projects Using'].split(', ');
    return `- **${tech}**: ${projects.length} project${projects.length > 1 ? 's' : ''} (${projects.join(', ')})`;
  }).join('\n');
})()}

## Proficiency Distribution

- **Expert:** ${userStack.filter(t => t.Proficiency === 'Expert').length} technologies
- **Advanced:** ${userStack.filter(t => t.Proficiency === 'Advanced').length} technologies
- **Intermediate:** ${userStack.filter(t => t.Proficiency === 'Intermediate').length} technologies
- **Beginner:** ${userStack.filter(t => t.Proficiency === 'Beginner').length} technologies

## Recent Activity (Last 30 Days)

${userStack.filter(t => {
  const lastUsed = new Date(t['Last Used']);
  const monthAgo = new Date();
  monthAgo.setDate(monthAgo.getDate() - 30);
  return lastUsed >= monthAgo;
}).sort((a, b) => new Date(b['Last Used']) - new Date(a['Last Used']))
  .slice(0, 10)
  .map(t => `- **${t.Technology}** - ${t['Last Used']} (${t['Projects Using']})`)
  .join('\n')}
`;

// Save report
const reportPath = path.join(os.homedir(), '.claude', '_fpcg_tags', 'tech-stack-report.md');
fs.writeFileSync(reportPath, report);

console.log(`✅ Report generated: ${reportPath}`);
console.log(report);
```

### Export to Excel

```javascript
// Note: For Excel export, you'll need to use a library like xlsx or exceljs
// This is a simplified version showing the structure

const XLSX = require('xlsx'); // Would need to be installed

const workbook = XLSX.utils.book_new();

// Sheet 1: Tech by Project
const projectSheet = XLSX.utils.json_to_sheet(projectStack);
XLSX.utils.book_append_sheet(workbook, projectSheet, 'By Project');

// Sheet 2: Tech by User
const userSheet = XLSX.utils.json_to_sheet(userStack);
XLSX.utils.book_append_sheet(workbook, userSheet, 'Skill Inventory');

// Sheet 3: Technology Matrix (Pivot)
const matrix = [];
const allTechs = [...new Set(userStack.map(t => t.Technology))];
const allProjects = [...new Set(projectStack.map(p => p.Project))];

// Create header row
const headerRow = ['Technology', ...allProjects];
matrix.push(headerRow);

// Create data rows
allTechs.forEach(tech => {
  const row = [tech];
  allProjects.forEach(project => {
    const userRow = userStack.find(t => t.Technology === tech);
    const usedInProject = userRow && userRow['Projects Using'].includes(project);
    row.push(usedInProject ? '✓' : '');
  });
  matrix.push(row);
});

const matrixSheet = XLSX.utils.aoa_to_sheet(matrix);
XLSX.utils.book_append_sheet(workbook, matrixSheet, 'Matrix');

// Sheet 4: Summary Stats
const stats = [
  ['Metric', 'Value'],
  ['Total Technologies', userStack.length],
  ['Total Projects', projectStack.length],
  ['Expert Level', userStack.filter(t => t.Proficiency === 'Expert').length],
  ['Advanced Level', userStack.filter(t => t.Proficiency === 'Advanced').length],
  ['Intermediate Level', userStack.filter(t => t.Proficiency === 'Intermediate').length],
  ['Currently Learning', userStack.filter(t => t['Learning Status'] === 'Learning').length],
  ['Frontend Tech', userStack.filter(t => t.Category === 'Frontend').length],
  ['Backend Tech', userStack.filter(t => t.Category === 'Backend').length],
  ['Database Tech', userStack.filter(t => t.Category === 'Database').length],
  ['DevOps Tech', userStack.filter(t => t.Category === 'DevOps').length],
];

const statsSheet = XLSX.utils.aoa_to_sheet(stats);
XLSX.utils.book_append_sheet(workbook, statsSheet, 'Stats');

// Write to file
const excelPath = path.join(os.homedir(), '.claude', '_fpcg_tags', 'tech-stack-report.xlsx');
XLSX.writeFile(workbook, excelPath);

console.log(`✅ Excel report exported: ${excelPath}`);
```

## Quick Visual Report (Markdown Table)

When user runs `/tech-stack`, show a compact matrix:

```markdown
# Tech Stack at a Glance

| Project | Frontend | Backend | Database | DevOps | Testing |
|---------|----------|---------|----------|--------|---------|
| llm-ad-platform-cc | ⭐⭐⭐⭐ React, TS | ⭐⭐⭐⭐ Node, Express | ⭐⭐⭐ PostgreSQL | ⭐⭐⭐ Docker | ⭐⭐⭐ Jest |
| my-custom-gpt | ⭐⭐⭐ Next.js | ⭐⭐⭐ Node.js | ⭐⭐⭐ MongoDB | ⭐⭐⭐ Vercel | ⭐⭐ Vitest |
| Claude-Code-Guide | ⭐⭐⭐ Markdown | ⭐⭐ Node.js | - | ⭐⭐⭐ GitHub Pages | - |

⭐⭐⭐⭐ Expert | ⭐⭐⭐ Advanced | ⭐⭐ Intermediate | ⭐ Beginner
```

## Integration with /tag Command

When a user tags a project with `/tag`, also prompt for tech stack:

```markdown
After tagging project, ask:

"Would you like to add the tech stack for this project? (y/n)"

If yes:
- Frontend technologies: [prompt]
- Backend technologies: [prompt]
- Database: [prompt]
- DevOps tools: [prompt]
- Testing frameworks: [prompt]

Auto-populate tech-stack-by-project.csv
```

## Auto-Detection from package.json

For smarter tech stack tracking:

```javascript
// Read package.json if it exists
const packageJsonPath = path.join(cwd, 'package.json');
if (fs.existsSync(packageJsonPath)) {
  const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  const deps = { ...pkg.dependencies, ...pkg.devDependencies };

  // Auto-detect common tech
  const detectedTech = {
    frontend: [],
    backend: [],
    testing: [],
    tools: []
  };

  if (deps.react) detectedTech.frontend.push('React');
  if (deps.next) detectedTech.frontend.push('Next.js');
  if (deps.typescript) detectedTech.frontend.push('TypeScript');
  if (deps.tailwindcss) detectedTech.frontend.push('Tailwind CSS');
  if (deps.express) detectedTech.backend.push('Express');
  if (deps.jest) detectedTech.testing.push('Jest');
  if (deps.playwright) detectedTech.testing.push('Playwright');

  console.log('🔍 Detected technologies from package.json:');
  console.log(`Frontend: ${detectedTech.frontend.join(', ')}`);
  console.log(`Backend: ${detectedTech.backend.join(', ')}`);
  console.log(`Testing: ${detectedTech.testing.join(', ')}`);
  console.log('\nAdd these to tech stack? (y/n)');
}
```

## Visualization Dashboard (Future)

Create HTML dashboard with charts:

```html
<!-- Generated dashboard -->
<!DOCTYPE html>
<html>
<head>
  <title>Tech Stack Dashboard</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
  <h1>FPCG Tech Stack Dashboard</h1>

  <div class="chart-container">
    <canvas id="proficiencyChart"></canvas>
    <canvas id="categoryChart"></canvas>
    <canvas id="projectCoverageChart"></canvas>
  </div>

  <script>
    // Proficiency distribution pie chart
    new Chart(document.getElementById('proficiencyChart'), {
      type: 'pie',
      data: {
        labels: ['Expert', 'Advanced', 'Intermediate', 'Beginner'],
        datasets: [{
          data: [8, 7, 6, 5] // From userStack
        }]
      }
    });

    // Category breakdown
    new Chart(document.getElementById('categoryChart'), {
      type: 'bar',
      data: {
        labels: ['Frontend', 'Backend', 'Database', 'DevOps', 'Testing', 'Tools'],
        datasets: [{
          label: 'Technologies',
          data: [5, 4, 3, 4, 3, 6] // From userStack
        }]
      }
    });
  </script>
</body>
</html>
```

## Examples

### Example 1: View Tech Stack

```bash
/tech-stack

# Output:
🛠️ Tech Stack Overview

📊 Technologies in Use
17 Proficient
6 Currently Learning
0 Want to Learn

🎯 By Category
Frontend: React, TypeScript, Tailwind CSS, Next.js, Markdown, Docusaurus
Backend: Node.js, Express, Python, OpenAI API
Database: PostgreSQL, Redis, MongoDB
DevOps: Docker, AWS, Vercel, GitHub Pages
Testing: Jest, Playwright, Vitest
Tools: Git, VS Code, Claude Code, Make.com, Asana, Obsidian

📈 Currently Learning
- Python (Intermediate) - ML/AI integrations
- Redis (Intermediate) - Caching and sessions
- AWS (Intermediate) - Cloud infrastructure
- Playwright (Intermediate) - E2E testing
- Vitest (Intermediate) - Vite-native testing
- Make.com (Advanced) - Workflow automation
```

### Example 2: Add Tech to Project

```bash
cd ~/Documents/GitHub/llm-ad-platform-cc
/tech-stack add

Technology: Prisma
Category: Database
Usage: ORM for PostgreSQL, type-safe queries
Proficiency: Intermediate

✅ Added Prisma to llm-ad-platform-cc tech stack
✅ Updated your personal tech inventory
```

### Example 3: Generate Report

```bash
/tech-stack report

✅ Report generated: ~/.claude/_fpcg_tags/tech-stack-report.md

[Displays full markdown report...]
```

### Example 4: Export to Excel

```bash
/tech-stack export

✅ Excel report exported: ~/.claude/_fpcg_tags/tech-stack-report.xlsx

File contains:
- Sheet 1: Tech by Project
- Sheet 2: Skill Inventory
- Sheet 3: Technology Matrix
- Sheet 4: Charts & Stats

Open with: start ~/.claude/_fpcg_tags/tech-stack-report.xlsx
```

## Related Commands

- `/tag` - Tag project (can include tech stack)
- `/projects` - List projects (can show tech stack column)

## Support Files

- **Projects:** `~/.claude/_fpcg_tags/tech-stack-by-project.csv`
- **User Skills:** `~/.claude/_fpcg_tags/tech-stack-by-user.csv`
- **Reports:** `~/.claude/_fpcg_tags/tech-stack-report.*`
- **Command:** `~/.claude/commands/tech-stack.md` (this file)

---

**End of /tech-stack command**

*Track and visualize your technology stack across all projects*
