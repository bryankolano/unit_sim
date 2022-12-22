# Army Officer Population Analysis
#### Bryan Kolano
#### August 19th, 2022
---

### Background

From July - August, 2022, I had to participate in the Qualification Course for Army Operations Research and Systems Analysts (ORSA) or in other words, the data scientists of the Army.  As part of this course, each member was part of a 6-7 person capstone project team.  A few weeks into the course, each capstone team received a real-world project from an Army organization.  Many of these projects were data analysis, but not all of them.  <br>

My team was assigned a project with a small army organization.  This organization has a population of about 50 members with some support staff.  The population consists of Army Lieutenant Colonels (LTC), Majors (MAJ), Captains (CPTs).  The organization had a listing of their current officer pool and the years of service of each officer.  The organization had no easily accessible historical data about its population of officers.  <br>

The organization had a large amount of LTCs but only a few MAJs and CPTs.  The LTCs, at some point, are going to leave the organization, either with a promotion to Colonel  (COL) or with their retirement.  LTC is typically the rank that an officer will retire from military service because most officers are LTCs when they hit 20 years of service and are first elegible to retire.  With the top heavy population and not a lot of MAJs and CPTs in the ranks, the organization wanted to know if they were going to have a shortage of ranks in 10 years.  Leadership in the organization asked the following queston: "Are we headed for a train wreck?"  <br>

Defining the problem was fairly straightforward, but determining how to best answer their unit's question was a little difficult because we had no historical data.  Giving that fact, and we generally can project an officer's career timeline (of promotion, retirement, and other reasons for leaving the army), we determine we could create a simulation that would use probabilities to track the population of officers and then simulate that numerous time to find general trends.

*Note: To protect the identity of the organization and their data and to get this project completely unclass, certain aspects of this project have been changed.  Additionally, the data for the project is representative of the real data but have been changed from the real data. *   

### Description of data and variables
To create the simulation, the team had to create numerous assumptions based on officer assessions into the unit and various probabilities.  Our capstone team used our knowledge of the officer career timelines to create and initial list of probabilities and then bounced them off of the unit to oogeto concurrence.  The following table are the list of assumptions and probabilities used during the simulation.

| Value | Description |
| ----------- | ----------- |
| 5% | Probably an officer will leave for any reason before retirement, aka UFR or unqualified Retirement |
| 25% | Probability a LTC will be promoted to COL |
|66% | Probability a MAJ will be promoted to LTC|
|80% | Probability a MAJ will be promoted to MAJ|
| triangular distribution (20,22,26)|Probability a LTC with more than 20 years of service will retire|
| 2 | Number of new MAJs to enter the organization each year
|triangular distribution (12, 15, 18)| The years of service probability of a newly assessed MAJ|
| 1 | Number of new MAJs to enter the organization each year|
|triangular distribution (6, 8, 11)| The years of service probability of a newly assessed CPT|

Additional assumptions:
- An officer not picked up for promotion one year, will have the same probabilistic chance the following year
- An officer not picked up two consecutive times, will have the chance to be picked up a third, fourth or even fifth time (In the army currently, an officer not picked up twice will be kicked out of the Army.)


### Initial Python Simulation

Immediately after our team's meeting with the unit reps, I thought a simulation would be the way to tackle the problem given lack of historic data while other team members though they might explore how we could use Markov Chains.  That night, I sat down to see how I could explore the current unit population to code a simulation in python.  After making a little progress, I got really motivated and ended up finishing the initial draft of the simulation that night, using my own guesses about probabilities.  
<br>

The following day, I shared the results with my team members.  They were pleased that I was able to create a simulation quickly, but they were less than pleased that I wrote it in python..... so they asked me if I would redo it in R.

### R Simulation
Most Army Operations Research and Systems Analysts (ORSAs), which is what I am in the army, are the Army's data scientists.  Most Army ORSAs that are coders write code in R, a small minority write in python.  I started off my coding journey in R, but switched to python a few years in for numerous reasons, though I will use R on occasion for different projects.  <br>

The team asked me to rewrite the simulation in R so that 1) They can understand what the code is doing and 2) They can perform sensitive analysis (changing the probability assumptions) to help the unit to understand how changes their their current operations may impact the size of their population in 10 years.  For example, if this unit can recruit three CPTs per year as opposed to the assumed one per year, then we can assess the impacts to the unit after hundreds or thousands of simulations.  <br>

It took me a day or two to rewrite the simulation in R.  After the code was written, the rest of the team and I did sensitivity analysis on the simulation as well as create a couple visualizations for the unit to see the state of their population for the next 10 years.  

### R Shiny Application
Although I spent a few years writting R code, I had never written an R Shiny application.  During our qualification course, we received a small block of instruction on R Shiny.  Our team members thought it might be a good idea to create an R Shiny application for our projects.  We could give the unit a couple of changeable parameters and then they can run the simulation and with the changed parameters.

This was the hardest part of whole capstone project since I was unfamiliar with Shiny.  Finally, I was able to get the R Shiny application working. It allows user to modify how many MAJs and CPTs a year they plan to/ would like to assess.  For example, if the unit wants to increase their recruitment efforts for the first three years and increase from 2 MAJs and 1 CPT to say 5 MAJs and 5 CPTs, then the app will update with the new graphs.  Additionally, the app allows the user to change the number of simulations run.  

![Shiny Screengrab](shiny_grab.jpg)

At the end, the unit had our team's outbrief based on the simulation and analysis, but also received the R Shiny app code in case they wanted to continue with their further analysis.  

Given more time with the project and the app, we could have continued to make the Shiny app more robust, with more inputs, but I believe the unit appreciated the work performed.


### Summary

After all that work in R, I wanted to bring the focus back to python.  Although we are done with the project with the supported unit, I wanted to continue to iterate on this project.  The current plan is to turn this project into a Plotly Dash application.  It would work similar to the R Shiny app.  I have never used Plotly Dash either, so this will be an exploration into creating a Dash app, and I think it will be educational and entertaining.