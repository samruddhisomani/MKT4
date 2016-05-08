# Marketing Analytics Team Project 4: Bayesian Variable Selection and Customer Scoring

### Team member:
  * Samruddhi Somani
  * Wenyue Shi
  * Vivian Chu
  * Reshma Sekar
  * Qijing Zhang


## Scoring Model

We fitted a GLM model to the data, filtered coefficients by significance (p<0.05), and ranked coefficients by absolute value. Here are the top coefficients before exponentiating them back to original scale:

![alt text](https://github.com/samruddhisomani/MKT4/blob/master/coef.png "Coefficients")

To improve interpretability, we exponentiated these coefficients:

![alt text](https://github.com/samruddhisomani/MKT4/blob/master/exp_coef.png "Exp Coefficients")

### Interpretation

We see that marital status has the largest impact on odds of responding: They are 22.83 times more likely to respond than unmarried people.  Men are roughly 8.57 times more likely to respond than females. Respondents to previous mailings similarly are 8.22 times more likely to respond. For each additional point of financial orientation, a person is 1.5 times more likely to respond. Likewise, for each additional household member, a person is 1.37 times more likely. Lastly, people who own small businesses are 1.18 times more likely to respond. 

## Validation on Holdout Data

After obtaining a GLM model, we used it to predict responses in the holdout data. We sorted the addresses by probability in descending order, and calculated the percentile of distribution of all addresses. Then, we tried to find the optimal top percentile to target. To do that, we plotted response rate against percentiles ranging from 0.01 to 5, with 0.01 increment:

![alt text](https://github.com/samruddhisomani/MKT4/blob/master/response.png "Reponse Rate")

After we mail the top 2 percentile addresses, response rate starts to flatten out. That means if we mail beyond top 2 percentile, marginal increase in response rate starts to decline. So 2 percentile is a reasonable number according to this graph.

[Optional question] To take a closer look at the optimal percentile, we factored in the fixed and variable costs, and value of lead. We computed the expected profits for percentiles from 0.01 to 5.