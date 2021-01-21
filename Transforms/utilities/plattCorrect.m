function [predictedScore] = plattCorrect(predictedLabel)
%PLATTCORRECT Transform SVM predicted label to score by training logistic
%regression model to predict predicted label
model = fitglm(predictedLabel, predictedLabel,'linear',...
    'Distribution','binomial');
predictedScore = predict(model,predictedLabel);
end

