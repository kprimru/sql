USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Ric].[PriceExcess]
(
	@PR_ALG	SMALLINT,
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(10, 4)

	DECLARE @PR_DATE	SMALLDATETIME

	SELECT @PR_DATE = PR_DATE
	FROM dbo.PeriodTable
	WHERE PR_ID = @PR_ALG

	DECLARE @REC	MONEY
	DECLARE	@CALC	MONEY
	
	DECLARE @SYS_LIST	VARCHAR(MAX)
	SET @SYS_LIST = ''

	IF @PR_DATE >= '20100101'
	BEGIN
		SELECT @SYS_LIST = @SYS_LIST + CONVERT(VARCHAR(20), SYS_ID) + ','
		FROM dbo.SystemTable
		WHERE SYS_REG_NAME IN 
			('LAW', 'BUH', 'ROS', 'QSA', 'FIN', 'ARB', 'PAP', 'CMT', 'KOR', 'EXP')

		SET @SYS_LIST = LEFT(@SYS_LIST, LEN(@SYS_LIST) - 1)

		SELECT @REC = SUM(PS_PRICE * SNCC_VALUE * TTP_COEF)
		FROM 
			dbo.PeriodRegExceptView
			INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
			INNER JOIN dbo.GET_TABLE_FROM_LIST(@SYS_LIST, ',') ON Item = REG_ID_SYSTEM
			INNER JOIN 
				(
					SELECT SNC_ID, SN_ID, SN_NAME, SNCC_VALUE
					FROM
						dbo.SystemNetCountTable 
						INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
						INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
					WHERE SNCC_ID_PERIOD = @PR_ID
				) AS g ON SNC_ID = REG_ID_NET
			INNER JOIN 
				(
					SELECT TT_ID, TT_REG, TT_NAME, TTP_COEF
					FROM
						dbo.TechnolTypeTable
						INNER JOIN dbo.TechnolTypePeriod ON TTP_ID_TECH = TT_ID
					WHERE TTP_ID_PERIOD = @PR_ID
				) AS y ON REG_ID_TECH_TYPE = TT_ID
			INNER JOIN dbo.PriceSystemTable ON PS_ID_SYSTEM = REG_ID_SYSTEM AND PS_ID_PERIOD = REG_ID_PERIOD AND PS_ID_TYPE = 16
		WHERE REG_ID_PERIOD = @PR_ID AND DS_REG = 0 

		SELECT @CALC = SUM(PS_PRICE * SNCC_VALUE * TTP_COEF)
		FROM 
			dbo.PeriodRegExceptView
			INNER JOIN dbo.DistrStatusTable ON DS_ID = REG_ID_STATUS
			INNER JOIN dbo.GET_TABLE_FROM_LIST(@SYS_LIST, ',') ON Item = REG_ID_SYSTEM
			INNER JOIN 
				(
					SELECT SNC_ID, SN_ID, SN_NAME, SNCC_VALUE
					FROM
						dbo.SystemNetCountTable 
						INNER JOIN dbo.SystemNetTable ON SN_ID = SNC_ID_SN
						INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
					WHERE SNCC_ID_PERIOD = @PR_ID
				) AS g ON SNC_ID = REG_ID_NET
			INNER JOIN 
				(
					SELECT TT_ID, TT_REG, TT_NAME, TTP_COEF
					FROM
						dbo.TechnolTypeTable
						INNER JOIN dbo.TechnolTypePeriod ON TTP_ID_TECH = TT_ID
					WHERE TTP_ID_PERIOD = @PR_ID
				) AS y ON REG_ID_TECH_TYPE = TT_ID
			INNER JOIN dbo.PriceSystemTable ON PS_ID_SYSTEM = REG_ID_SYSTEM AND PS_ID_PERIOD = REG_ID_PERIOD AND PS_ID_TYPE = 1
		WHERE REG_ID_PERIOD = @PR_ID AND DS_REG = 0 

		SET @RES = ROUND((@CALC / @REC - 1) * 100, 2)
	END

	RETURN @RES 
END
