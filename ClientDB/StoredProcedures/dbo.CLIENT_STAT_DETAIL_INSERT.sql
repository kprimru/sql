USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_STAT_DETAIL_INSERT]
	@DISTR			INT,
	@COMP			INT,
	@NET			NVARCHAR(256),
	@USER_COUNT		INT,
	@ENTER_SUM		INT,
	@ZERO_ENTER		INT,
	@ONE_ENTER		INT,
	@TWO_ENTER		INT,
	@THREE_ENTER	INT,
	@SES_TIME_SUM	INT,
	@SES_TIME_AVG	FLOAT,
	@WEEK_NUM		INT
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO dbo.ClientStatDetail ([UpDate], WeekId, HostId, Distr, Comp, Net, UserCount, EnterSum, [0Enter], [1Enter], [2Enter], [3Enter], SessionTimeSum, SessionTimeAVG)
	SELECT
		GETDATE(),
		(
		SELECT ID
		FROM Common.Period
		WHERE TYPE=1 AND START=(
								SELECT TOP(1) START
								FROM Common.Period
								WHERE TYPE=1 AND DATEPART(yy, START)=DATEPART(yy, GETDATE()) AND DATEPART(ww, START)=@WEEK_NUM
								ORDER BY START DESC
								)
		),
		1,
		@DISTR,
		@COMP,
		@NET,
		@USER_COUNT,
		@ENTER_SUM,
		@ZERO_ENTER,
		@ONE_ENTER,
		@TWO_ENTER,
		@THREE_ENTER,
		@SES_TIME_SUM,
		@SES_TIME_AVG
END;