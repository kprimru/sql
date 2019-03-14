USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_ADD] 
	@systemid SMALLINT,
	@periodid SMALLINT,
	@weight DECIMAL(8, 4),
	@problem BIT,
	@active BIT = 1,
	@replace BIT = 0,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.SystemWeightTable(SW_ID_SYSTEM, SW_ID_PERIOD, SW_WEIGHT, SW_PROBLEM, SW_ACTIVE) 
	VALUES (@systemid, @periodid, @weight, @problem, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	IF @replace = 1
	BEGIN
		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @periodid

		INSERT INTO dbo.SystemWeightTable(SW_ID_SYSTEM, SW_ID_PERIOD, SW_WEIGHT, SW_PROBLEM, SW_ACTIVE)
			SELECT @systemid, PR_ID, @weight, @problem, 1
			FROM dbo.PeriodTable
			WHERE PR_DATE > @PR_DATE
	END

	SET NOCOUNT OFF
END







