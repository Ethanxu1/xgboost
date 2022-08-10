args = commandArgs(trailingOnly=TRUE)

file1=args[1]
file2=args[2]
procid=args[3]
# *************************************************************
# Xgboost Regression Load model and predic test set
# 
# yuanyuan.li@nih.gov
# created : 01-22-2022
# *************************************************************
options("expressions"=500000) #max no. nested iterations
require(xgboost)
require(MLmetrics)
require(vcd)
require(e1071)

# Path to 1000 models
#model_loc <- ('/Users/liy19/gb/po/xgboost_po/s2609/Do/model/model/')

#model_loc <- ('/var/www/cgi-bin/XGBoost/txt/')
#model_loc<-('/var/www/cgi-bin/XGBoost/jason/json/')
model_loc<-('/var/www/cgi-bin/xgboost/model/')

num_model = 10
MAX_LBL   = 0.9975     # Make sure never == 1

# ========== Read in data ==========
# Load testing data file (10 genes' expression values)
filename <- paste0("./tmp/",file1)
dat <- read.table(filename,sep=",",header=T)
dat <- data.matrix(dat[,!names(dat)=="gene"])   # Sample X Gene
# Load testing tumor purity (ground truth)
filename <- paste0("./tmp/",file2)
lbl <- read.table(filename,sep=",",header=T)   # Purity value [0, 1]
lbl <- lbl[,2]
lbl[lbl==1]=MAX_LBL #  - Note: Take care lbl==1

# logistic transform (log[p/(1-p)])
lbl_log <- log(lbl/(1-lbl))

# Load data into xgb.DMartix (Label is optional)
dtest  <- xgb.DMatrix(data=dat, label=lbl_log)

# Get number of testing data
num_test <- dim(dat)[1]

#===== XGBoost ensemble learning & predictions ======
#print('- learning & predicting')
ptst_all <- matrix(0, num_model, num_test) # Final test prediction

# For each model, predict test set data, save to predictions to ptst_all
MODELS=list.files(path=model_loc, pattern=".model", all.files=T, full.names=T)
for (i in 1:num_model){

    # Load current model
    bst <- try(xgb.load(MODELS[i]))

    # Predict test set using current model
    ptst_log <- predict(bst, dtest)

    # Inverse logit transform (exp(x)/(1+exp(x)))
    ptest <- exp(ptst_log)/(1+exp(ptst_log))

    ## RMSE between predicted and ground truth (if any)
    #rmse <- RMSE(ptest, lbl)
    
    # Save current prediction
    ptst_all[i,] <- ptest

}#end-for all 1000 xgboost models



#===== Calculate final test set prediction from all models' predictions ====
#print('- Final test predictions')
# Average of all 1000 predictions
ptst_pred = colMeans(ptst_all)
write.table(ptst_pred,paste0("./tmp/pred",procid,".txt"))
#print('- done')


