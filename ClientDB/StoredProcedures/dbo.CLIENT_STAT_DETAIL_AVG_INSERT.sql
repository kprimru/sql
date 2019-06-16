USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_STAT_DETAIL_AVG_INSERT]
	@WEEK_NUM					INT,
	@NET						NVARCHAR(256),
	@COMPL_COUNT				INT,
	@COMPL_NO_ENT				INT,
	@COMPL_WITH_ENT				INT,
	@ENTER_COUNT				INT,
	@USER_COUNT					INT,
	@ZERO_ENTER					INT,
	@ONE_ENTER					INT,
	@TWO_ENTER					INT,
	@THREE_ENTER				INT,
	@AVG_USER_COUNT				FLOAT,
	@AVG_WORK_USER_COUNT		FLOAT,
	@AVG_NWORK_USER_COUNT		FLOAT,
	@AVG_ENTER_COUNT			FLOAT,
	@AVG_WORK_USER_ENTER_COUNT	FLOAT,
	@AVG_SESSION_TIME			FLOAT
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO dbo.ClientStatDetailAVG([UpDate],
										WeekId,
										Net,
										ComplCount,
										ComplNoEnt,
										ComplWithEnt,
										EntCount,
										UserCount,
										[0Enter],
										[1Enter],
										[2Enter],
										[3Enter],
										AVGUserCount,
										AVGWorkUserCount,
										AVGNWorkUserCount,
										AVGEntCount,
										AVGWorkUserEntCount,
										AVGSessionTime
										)
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
			@NET,
			@COMPL_COUNT,
			@COMPL_NO_ENT,
			@COMPL_WITH_ENT,
			@ENTER_COUNT,
			@USER_COUNT,
			@ZERO_ENTER,
			@ONE_ENTER,
			@TWO_ENTER,
			@THREE_ENTER,
			@AVG_USER_COUNT,
			@AVG_WORK_USER_COUNT,
			@AVG_NWORK_USER_COUNT,
			@AVG_ENTER_COUNT,
			@AVG_WORK_USER_ENTER_COUNT,
			@AVG_SESSION_TIME;
END;