/*
SELECT *
FROM dbo.PeriodTable
*/

DECLARE
	@Start		SmallDateTime,
	@Finish		SmallDateTime,
	@RStart		SmallDateTime,
	@RFinish	SmallDateTime;
	
SET @Start = '20220101';
SET @RStart = '20211228'

WHILE (1 = 1) BEGIN
	IF @Start = '20710101'
		BREAK;
		
	SET @Finish = DateAdd(Day, -1, DateAdd(Month, 1, @Start));
	
	-- идем в 25е число и смотрим, какой это день недели
	SET @RFinish = DateAdd(Day, 24, @Start);
	IF DateName(weekday, @RFinish) = 'суббота'
		SET @RFinish = DateAdd(Day, 2, @RFinish);
	IF DateName(weekday, @RFinish) = 'воскресенье'
		SET @RFinish = DateAdd(Day, 1, @RFinish);
	
	INSERT INTO dbo.PeriodTable(PR_NAME, PR_DATE, PR_END_DATE, PR_BREPORT, PR_EREPORT, PR_ACTIVE)
	SELECT Convert(VarChar(20), @Start, 104), @Start, @Finish, @RStart, @RFinish, 0
	
	SET @Start = DateAdd(Month, 1, @Start);
	SET @RStart = DateAdd(Day, 1, @RFinish)
END;