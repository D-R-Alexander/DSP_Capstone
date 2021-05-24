Project Requirements:

1. Report in Rmd format
2. Report in PDF format (knit from your Rmd file)
3. Script in R format that generates predicted movie ratings and RMSE score 
    (should contain all code and comments for your project)

REPORT:
Documents the analysis and presents the findings, along with supporting statistics and figures. The report must be written in English and uploaded. The report should be written assuming that the reader is not familiar with the project or the data. The report must include the RMSE generated. The report must include at least the following sections:

- Introduction/overview/executive summary section that describes the dataset and summarizes the goal of the project and key steps that were performed

- Methods/analysis section that explains the process and techniques used, including data cleaning, data exploration and visualization, insights gained, and your modeling approach

- Results section that presents the modeling results and discusses the model performance

- Conclusion section that gives a brief summary of the report, its limitations and future work

CODE:
The code in the R script should should be well-commented and easy to follow. The code provided in the R script should contain all of the code and comments 
for your project. You are not required to run the code provided (although you may if you wish), but you should visually inspect it. You will use the following code to generate your datasets. Develop your algorithm using the edx set. 

RMSE:
Provide the appropriate score given the reported RMSE. Please be sure not to use the validation set (the final hold-out test set) for training or regularization - you should create an additional partition of training and test sets from the provided edx dataset to experiment with multiple parameters or use cross-validation

- 20%: RMSE >= 0.90000 AND/OR the reported RMSE is the result of overtraining (validation set - the final hold-out test set - ratings used for anything except reporting the final RMSE value) AND/OR the reported RMSE is the result of simply copying and running code provided in previous courses in the series

- 40%: 0.86550 <= RMSE <= 0.89999
- 60%: 0.86500 <= RMSE <= 0.86549
- 80%: 0.86490 <= RMSE <= 0.86499
- 100%: RMSE < 0.86490

##########
For a final test of your final algorithm, predict movie ratings in the validation set (the final hold-out test set) as if they were unknown. RMSE will be used to evaluate how close your predictions are to the true values in the validation set (the final hold-out test set).

Important: The validation data (the final hold-out test set) should NOT be used for training, developing, or selecting your algorithm and it should ONLY be used for evaluating the RMSE of your final algorithm. The final hold-out test set should only be used at the end of your project with your final model. It may not be used to test the RMSE of multiple models during model development. You should split the edx data into separate training and test sets to design and test your algorithm.