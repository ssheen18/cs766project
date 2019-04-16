function result = evaluateResult(groundTruth, predicted) 
    TP = sum(sum(predicted & groundTruth));
    FP = sum(sum(predicted & (groundTruth == 0)));
    TN = sum(sum((predicted == 0) & (groundTruth == 0)));
    FN = sum(sum((predicted == 0) & groundTruth));
    
    accuracy = (TP + TN) / (TP + FP + TN + FN);
    precision = TP / (TP + FP);
    recall = TP / (TP + FN);
    
    fprintf('Accuracy: %4.4f\n', accuracy);
    fprintf('Precision: %4.4f\n', precision);
    fprintf('Recall: %4.4f\n', recall);
    
    
    result = 'done';
    
    
    