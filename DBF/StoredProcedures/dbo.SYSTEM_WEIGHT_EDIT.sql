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

CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_EDIT] 
	@swid INT,
	@systemid SMALLINT,
	@periodid SMALLINT,
	@weight DECIMAL(8, 4),
	@problem BIT,
	@active BIT,
	@replace BIT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.SystemWeightTable
	SET 
		SW_ID_SYSTEM = @systemid,
		SW_ID_PERIOD = @periodid, 
	    SW_WEIGHT = @weight,
		SW_PROBLEM = @problem,
		SW_ACTIVE = @active
	WHERE SW_ID = @swid

	IF @REPLACE = 1
	BEGIN
		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @periodid

		UPDATE dbo.SystemWeightTable
		SET SW_WEIGHT = @weight
		FROM 
			dbo.SystemWeightTable
			INNER JOIN dbo.PeriodTable ON PR_ID = SW_ID_PERIOD
		WHERE PR_DATE > @PR_DATE AND SW_ID_SYSTEM = @systemid AND SW_PROBLEM = @problem
	END
	SET NOCOUNT OFF
END







