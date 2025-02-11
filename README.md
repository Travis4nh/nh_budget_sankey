
This is a tool that can be used to analyze the NH state budget.

It has several modes of operation (discussed below).

# Installation


1. Download or git clone this package.
1. make sure you have ruby installed (`sudo apt-get install ruby` on Ubuntu)
1. make sure you have image magick installed (`sudo apt-get install imagemagick` on Ubuntu)
1. `git clone git@github.com:cbdevnet/piechart.git`
1. `cd piedchart`
1. `make`
1. `make install`
1. `cd ..`
1. `bundle update`

# Use

All use models start with these two steps:

1. clear existing data: `rake budget:clear`
1. import data: `rake budget:import .rakefile_NH_STATE.yaml`


## Generating a Sankey diagram

After the above steps:

3. generate sankey from imported data: `rake budget:sankey > sankey.txt`

or, the above three bundled:

* `rake budget:quick .rakefile_NH_STATE.yaml  > sankey.txt`

Once you have `sankey.txt`, upload it to https://sankeymatic.com/build/

![sankey chart example](./docs/sankey.jpeg)

## Source of data

Data files are stored in `./data`.  Data files have various configurations; each one needs a matching `.rakefile_FOO.yaml` that explains to the tool how to parse the data file.

You can add new data files in `./data` and write a matching `.rakefile` to go with it.

## Analyze the budget looking for weird outliers

Once you've loaded data (as per above)  you can 

3. `rake budget:analyze`

You will get text output, which lists each category of spending (along
with what percentage of its entire budget the average NH department
spends), and then lists the top 10 state departments ranked by actual
percentile spending in this cost category.

e.g.

```
---- 019-Holiday Pay avg = 1.28%, std_dev = 7.00 points 
  * 51.79% +  8 std devs    013-PEASE DEVELOPMENT AUTHORITY
  *  4.95% +  1 std devs    046-CORRECTIONS DEPT
  *  4.53% +  1 std devs    043-VETERANS HOME
  *  3.97% +  1 std devs    094-HHS: NH HOSPITAL
  *  2.88% +  0 std devs    096-TRANSPORTATION DEPT
  *  2.29% +  0 std devs    023-SAFETY DEPT
  *  1.72% +  0 std devs    091-HHS: GLENCLIFF HOME
  *  0.98% +  0 std devs    090-HHS: PUBLIC HEALTH DIV
  *  0.32% +  0 std devs    027-EMPLOYMENT SECURITY DEPT
  *  0.30% +  0 std devs    042-HHS: HUMAN SERVICES DIV
```

shows that the average department spends 1.28% of its budget on
holiday pay, but the Pease Development Authority spends 51.79% of its
budget on this.

## Analyze departments

This option is the reverse of "analyzing by categories" (above).  This analyzes by department.

For each department, break down how it spends money (and prints it to std out)

Also generates on piechart per department and writes it to `/tmp`.

1. `rake budget:department`

e.g.

![pie chart example](./docs/piechart.jpeg)

## Find alarming headcount numbers

1. `rake budget:headcount`


## Future directions

1. add in revenue sources
1. add in a tool to print out revenue sources from largest to smallest, so we can see what taxes might be entirely cut
1. see if we can find more information on programs within departments.  It's good to know that "HHS: Public Health Division" spent $100 million dollars, and it's good to know what percent of that went to IT and phones ...but what was it DOING?
1. ...and generate bar graph as per [a google sheet I created](https://docs.google.com/spreadsheets/d/1cYXZCm7VYefe_cPtn6cgwhq_7w-7Rti7Ehcf_h9D8SI/edit?usp=sharing)
1. import multiple years of NH state budgets, so that we can look for outliers where departments grew their budgets especially quickly.
1. perhaps use a database to instead of in-memory data structures (hashes) to hold data
1. add the capability to analyze town budgets
1. use a different sankey library so that we're not dependent on a web tool
1. ...and maybe allow the user to turn on and off flows out of certain departments in the UI so they're not overwhelmed with pixels
1. fix the pie charts to use consistent colors for spending categories across departments
1. fix the pie charts to not clip text
1. add tests ; use Husky to require pass before commit
1. add rubocop; use Husky to require before commit
1. follow one really egregious use of money to its source, add who’s in charge of budget at each stage, print the whole thing out on a large format printer in large distance-readable font and then unroll the massive exhibit in session; massive theater
1. add a module that scrapes all NH NGO 990 info https://projects.propublica.org/nonprofits/api and puts their cash flows into the graph, e.g ```
  curl --get --data-urlencode q='Planned Parenthood New Hampshire Action' https://projects.propublica.org/nonprofits/api/v2/search.json
  curl --get https://projects.propublica.org/nonprofits/api/v2/organizations/465554692.json
``` apparently schedule B (list of donors) is no longer public information.
1. 


# Other Data sources

## NH

- https://www.das.nh.gov/accounting/FY%2023/FY_2023_Annual_Comprehensive_Financial_Report_ACFR.pdf
- https://gencourt.state.nh.us/lba/Revenues/FY%2026-27/REVISED%20FY19-25%20GF%20ETF%20Revenue%20Collection%20(Thru%2011-30-2024).pdf

- previous year budgets
  - 2024 Jan 19 -Eagen, Scott, asked about finer-grained data
  - 2024 Jan 6 - Eagen, Scott scott.t.eagen@das.nh.gov provided this link https://www.das.nh.gov/accounting/previous_years.aspx
  - 2024 Jan 6 - asked him for excel, not just PDF

- Local and State police re NBIRS
  - 2025 Jan 21 - emailed SPHeadquarters@dos.nh.gov
  - 2024 Dec 26 - emailed christopher.moore@wearepolice.com ... he directed me to State police

## Weare, NH

- 2024 Jan 6 SAU 24 has minimal useful data [web page](https://www.sau24.org/schools/centerwoods/about-us/budget-information)
  - [google drive - Weare Center Woods](https://drive.google.com/drive/folders/1syPk3xqqWF8bQuBfnBFwwb9s5CmUbiL-)
  - [google drive - John Connor](https://drive.google.com/drive/folders/1TrNdKOtioKx0uF_12HeNC0NLKcS2kV8sX)
- 2024 Jan 6 left voicemail for Beth Rouse asking for town budgets (603) 529-7526

https://www.education.nh.gov/who-we-are/division-of-educator-and-analytic-resources/iplatform

# Related / other projects

Non profit explorer

- UI: https://joeisdone.github.io/expose/
- repo: https://github.com/joeisdone/joeisdone.github.io

# Authorship

This package was written by [Travis Corcoran](https://en.wikipedia.org/wiki/Travis_Corcoran).  I am a state rep in NH and you can find me on twitter at [@travis4nh](https://x.com/travis4nh).

# Licensing

This package is not yet licensed.  I'll almost certainly open source it.

# Canonical location

[https://github.com/Travis4nh/nh_budget_sankey](https://github.com/Travis4nh/nh_budget_sankey)

# Bug reports and feature requests

Please feel free to [create a ticket](https://github.com/Travis4nh/nh_budget_sankey/issues).


# Internal notes
- rvm use 3.3.5
- rails new nh9