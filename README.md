# Predict.Blood.Donations
Given our mission, we're interested in predicting if a blood donor will donate within a given time window.

Blood donation has been around for a long time. The first successful recorded transfusion was between two dogs in 1665, and the first medical use of human blood in a transfusion occurred in 1818. Even today, donated blood remains a critical resource during emergencies.

Our dataset is from a mobile blood donation vehicle in Taiwan. The Blood Transfusion Service Center drives to different universities and collects blood as part of a blood drive. We want to predict whether or not a donor will give blood the next time the vehicle comes to campus.

# Problem Description
Predict if the donor will give in March 2007
The goal is to predict the last column, whether he/she donated blood in March 2007.

Use information about each donor's history
- Months since Last Donation: this is the number of monthis since this donor's most recent donation.
- Number of Donations: this is the total number of donations that the donor has made.
- Total Volume Donated: this is the total amound of blood that the donor has donated in cubuc centimeters.
- Months since First Donation: this is the number of months since the donor's first donation.

# Algorithms Used
Decision Tree

Logistic Regression

MARSpline - Forward Pruning

MARSpline - Backward Pruning

MARSpline  - Cross Validation

xgBoost - Basic Method

xgBoost - Advanced

# Least Log Loss Algosrithms
Logistic Regression - 0.4488

MARSpline Forward Pruning - 0.4488

MARSpline Backward Pruning - 0.4541

MARSpline Cross Validation - 0.4541

xgBoost Advance - 0.5532

xgBoost Basic - 0.5532


Current Rank - 668
