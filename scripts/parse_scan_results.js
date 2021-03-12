#!/usr/bin/env node
const input = process.argv[2] || '';
let json_data = require(`${input}`);
let markDownString = '';

const getSeverityString = (input) => {
  const severities = {
    high:   `![#b51b72](https://via.placeholder.com/15/b51b72/000000?text=+) \`High\``,
    medium: `![#e29022](https://via.placeholder.com/15/e29022/000000?text=+) \`Medium\``,
    low:    `![#222049](https://via.placeholder.com/15/222049/000000?text=+) \`Low\``,
  }
  return severities.hasOwnProperty(input.severity)
    ? `${severities[input.severity]} severity found in \`${input.name}\``
    : `Unknown severity found in ${input.name}`;
};

let vulnTracker = new Set();
const vulnOutput = json_data.vulnerabilities.reduce((acc, curr) => {
  let tempStr = '';
  if (!vulnTracker.has(curr.title)) {
    tempStr+=(`#### ${getSeverityString(curr)}`);
    tempStr+=(`\n**Description**: [${curr.title}](https://snyk.io/vuln/${curr.id}) `);
    tempStr+=(`\\\n**Introduced through**: ${curr.from.join(' -> ')}`);
    tempStr+=(`\\\n**Introduced by** your base image (${curr.dockerBaseImage})`);
    (curr.nearestFixedInVersion) ? tempStr+= (`\\\n\`Fix available\` in: ${curr.nearestFixedInVersion} `) : '';

    tempStr+=(`\n\n`);
  }

  vulnTracker.add(curr.title);
  return acc + tempStr;
}, '');

markDownString+=(
  `\n\nTested ${json_data.dependencyCount} dependencies for ` +
  `known issues with the severity filter set to **${process.env.SEVERITY_THRESHOLD}**. ` +
  `Found *${json_data.uniqueCount}* ${json_data.uniqueCount > 1 ? 'issues' : 'issue'}.\n\n` +
  `Please review our [best practices for containers](https://docs.deliveroo.net/security/container_best_practices.html) ` +
  `and our [vulnerability management framework](https://docs.deliveroo.net/security/vulnerability_management_framework.html)\n\n` +
  `<details>
  <summary>Click to see details</summary>\n
`);

markDownString+=(vulnOutput);


/* Ok, lets grab the remediation advice. We pretty much need to split up the 
 *  * message strings and determine if theres 5 or more spaces in between */
const isMessageTable = (input)  => (!!input.match(/\s{2}/));
const advisoryTable = json_data.docker.baseImageRemediation.advice;
const convertAdvisoryToArray = message =>
  message
    .split(/\s{2,}/g)
    .reduce((acc, curr) => [...acc, ...curr.split("\n")], [])
    .filter(x => x);

const convertArrayToMarkdownTable = (arr) => {
  const [base, vuln, sev, ...rest] = arr;
  const [b, count, stats] = rest;
  const str = [``,
    `${base} | ${vuln} | ${sev}`,
    `:--- | :--- | :---`,
    `${b} | ${count} | ${stats}\n`
  ].map((x) => `${x}\n`).join('');
  return str;
};


advisoryTable.map((x, idx) => { 
  if (isMessageTable(x.message)) {
    const arr = convertAdvisoryToArray(x.message);
    const table = convertArrayToMarkdownTable(arr);
    markDownString+=(table);
  }
  else if (x.bold) {
    markDownString+=(`\n\n**${x.message.replace('\n', '')}**\n`);
  }
});

markDownString+=(`</details>`);
(vulnOutput.length > 1)  && console.log(markDownString);

