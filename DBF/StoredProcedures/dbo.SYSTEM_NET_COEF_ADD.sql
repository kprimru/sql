USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[SYSTEM_NET_COEF_ADD] 
	@NET		SMALLINT,
	@PERIOD		SMALLINT,
	@COEF		DECIMAL(8, 4),
	@WEIGHT		DECIMAL(8, 4),
	@SUBHOST	DECIMAL(8, 4),
	@ROUND		SMALLINT,
	@ACTIVE		BIT = 1,
	@REPLACE	BIT = 0,
	@RETURN		BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.SystemNetCoef(SNCC_ID_SN, SNCC_ID_PERIOD, SNCC_VALUE, SNCC_WEIGHT, SNCC_SUBHOST, SNCC_ROUND, SNCC_ACTIVE) 
		VALUES (@NET, @PERIOD, @COEF, @WEIGHT, @SUBHOST, @ROUND, @ACTIVE)

	IF @RETURN = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	IF @replace = 1
	BEGIN
		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PERIOD

		INSERT INTO dbo.SystemNetCoef(SNCC_ID_SN, SNCC_ID_PERIOD, SNCC_VALUE, SNCC_WEIGHT, SNCC_SUBHOST, SNCC_ROUND, SNCC_ACTIVE)
			SELECT @NET, PR_ID, @COEF, @WEIGHT, @SUBHOST, @ROUND, @ACTIVE
			FROM dbo.PeriodTable
			WHERE PR_DATE > @PR_DATE
	END

	SET NOCOUNT OFF
END