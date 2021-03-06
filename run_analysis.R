library(reshape2)
traindata<-read.table("UCI HAR Dataset/train/X_train.txt")
testdata<-read.table("UCI HAR Dataset/test/X_test.txt")
features<-read.table("UCI HAR Dataset/features.txt")
alldata<-rbind(traindata,testdata)
colnames(alldata)=features[,2]
meanfeatures<-grep("mean",features[,2],ignore.case = TRUE)
stdfeatures<-grep("-std()",features[,2])
featuresToKeep<-c(meanfeatures,stdfeatures)
alldataMeanStd<-alldata[,featuresToKeep]
alldataMeanStd<-cbind(alldataMeanStd,1:nrow(alldataMeanStd))
colnames(alldataMeanStd)[ncol(alldataMeanStd)]<-'rowid'
activitylables<-read.table("UCI HAR Dataset/activity_labels.txt")
colnames(activitylables)<-c('activityid','activityname')
ytraindata<-read.table("UCI HAR Dataset/train/y_train.txt")
ytestdata<-read.table("UCI HAR Dataset/test/y_test.txt")
ydata<-rbind(ytraindata,ytestdata)
ydata<-cbind(ydata,c(1:nrow(ydata)))
colnames(ydata)<-c('activityid','rowid')
labels<-merge(ydata,activitylables)
datawithlabel<-merge(alldataMeanStd,labels)
trainsubject<-read.table("UCI HAR Dataset/train/subject_train.txt")
testsubject<-read.table("UCI HAR Dataset/test/subject_test.txt")
subjects<-rbind(trainsubject,testsubject)
subjects<-cbind(subjects,1:nrow(subjects))
colnames(subjects)<-c('subject','rowid')
datawithlabelsubject<-merge(datawithlabel,subjects)
datawithlabelsubject<-datawithlabelsubject[,-which(names(datawithlabelsubject) %in% c("rowid","activityid"))]
meltdata<-melt(datawithlabelsubject,id=c("activityname","subject"))
castdata<-dcast(meltdata,paste(activityname,subject) ~ variable,mean)
colnames(castdata)[1]<-'activitysubject'
dataresult<-castdata %>% mutate(activity=substr(activitysubject,1,regexpr(" ",activitysubject)-1),subject=substr(activitysubject,regexpr(" ",activitysubject)+1,nchar(activitysubject)))
dataresult$subject<-as.numeric(dataresult$subject)
o1<-c(ncol(dataresult)-1,ncol(dataresult))
o2<-c(2:(ncol(dataresult)-2))
dataresult2<-dataresult[,c(o1,o2)]
write.table(dataresult2,file="project_result.txt",row.names = FALSE)
