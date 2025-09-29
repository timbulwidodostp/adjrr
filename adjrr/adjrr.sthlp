{smcl}
{cmd:help adjrr}{right: ({browse "http://www.stata-journal.com/article.html?article=st0306":SJ13-3: st0306})}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col:{hi:adjrr} {hline 2}}Computing adjusted risk ratios and risk
differences in Stata{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:adjrr}
{varname}
[{it:{help if}}]
[{cmd:,} {opt x0(value0)} {opt x1(value1)} {opt at(atspec)}]

{phang}where {it:varname} is the covariate of interest and must be a
covariate in the model run before this postestimation command.


{title:Description}

{pstd}
{cmd:adjrr} calculates the adjusted risk ratio
(ARR) and adjusted risk difference (ARD) with delta-method standard
errors for the covariate of interest.  The command is written to run
immediately after fitting a logit or probit model with a binary, a
multinomial, or an ordered outcome.  As when evaluating a binary
variable, the default sets the baseline value equal to 0 and the
resulting value equal to 1.  The available options allow the user to set
either the baseline value or the resulting value or both to
policy-relevant values.  The command automatically adjusts to
incorporate complex survey design if included in the user's previously
fit model.

{pstd}
This command reports the ARR, the ARD, the baseline risk, and the
exposed risk with their delta-method standard errors and 95% confidence
intervals.  In addition, two p-values are reported.  One p-value is from
a linear test of equivalence between the baseline and exposed risks.
The second p-value is from a nonlinear test that the natural log of the
ARR is equal to 0.  The 95% confidence interval for the ARR is estimated
first on the log scale before the endpoints are exponentiated.


{title:Options}

{phang}
{opt x0(value0)} specifies the baseline value at which to
evaluate the covariate of interest.  The default is {cmd:x0(0)}.

{phang}
{opt x1(value1)} specifies the resulting value at which to
evaluate the covariate of interest.  The default is {cmd:x1(1)}.

{phang}
{opt at(atspec)} specifies values of other covariates in the model.


{title:Examples}

{phang}{cmd:. logit insured female age race_bl race_oth, nolog}{p_end}
{phang}{cmd:. adjrr female}{p_end}
{phang}{cmd:. adjrr age, x0(20) x1(30)}{p_end}

{phang}{cmd:. probit insured female age race_bl race_oth, nolog}{p_end}
{phang}{cmd:. adjrr female}{p_end}
{phang}{cmd:. adjrr age, x0(20) x1(30)}{p_end}
{phang}{cmd:. adjrr female if race_bl == 1}{p_end}

{phang}{cmd:. mlogit ins_group female age race_bl race_oth, nolog}{p_end}
{phang}{cmd:. adjrr female}{p_end}

{phang}{cmd:. oprobit ins_group female age race_bl race_oth, nolog}{p_end}
{phang}{cmd:. adjrr female}{p_end}

{phang}{cmd:. logit diabetes i.female age female#c.age black orace, nolog}{p_end}
{phang}{cmd:. adjrr female}{p_end}
{phang}{cmd:. adjrr female, at((mean) age)}{p_end}

{phang}{cmd:. svy: logit diabetes i.female age female#c.age black orace, nolog}{p_end}
{phang}{cmd:. adjrr female}{p_end}


{title:Stores results}

{pstd}{cmd:adjrr} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(R0)}}baseline risk{p_end}
{synopt:{cmd:r(R0_se)}}baseline risk standard error{p_end}
{synopt:{cmd:r(R1)}}exposed risk{p_end}
{synopt:{cmd:r(R1_se)}}exposed risk standard error{p_end}
{synopt:{cmd:r(ARR)}}ARR{p_end}
{synopt:{cmd:r(ARR_se)}}ARR standard error{p_end}
{synopt:{cmd:r(ARD)}}ARD{p_end}
{synopt:{cmd:r(ARD_se)}}ARD standard error{p_end}
{synopt:{cmd:r(pvalue)}}p-value for linear test R0 = R1{p_end}
{p2colreset}{...}

{pstd}
Note: For models with a multinomial or an ordered outcome, all
scalars except for the number of observations will be indexed by the
outcome.


{title:Authors}

{pstd}Edward C. Norton{p_end}
{pstd}Departments of Health Management & Policy and Economics{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}ecnorton@umich.edu{p_end}

{pstd}Morgen M. Miller{p_end}
{pstd}Departments of Health Management & Policy and Economics{p_end}
{pstd}University of Michigan{p_end}
{pstd}Ann Arbor, MI{p_end}
{pstd}mmmill@umich.edu{p_end}

{pstd}Lawrence C. Kleinman{p_end}
{pstd}Departments of Health Evidence & Policy and Pediatrics{p_end}
{pstd}Mount Sinai School of Medicine{p_end}
{pstd}New York, NY{p_end}
{pstd}lawrence.kleinman@mssm.edu


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 13, number 3: {browse "http://www.stata-journal.com/article.html?article=st0306":st0306}{p_end}
