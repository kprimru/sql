USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Subhost].[SUBHOST_CALC_CLOSE]
	@SH_ID				SMALLINT,
	@PR_ID				SMALLINT,
	@SCR_DELIVERY_SYS	MONEY, 
	@SCR_SUPPORT		MONEY, 
	@SCR_CNT			SMALLINT, 
	@SCR_CNT_SPEC		SMALLINT, 
	@SCR_DIU			MONEY, 
	@SCR_PAPPER			MONEY, 
	@SCR_MARKET			MONEY, 
	@SCR_STUDY			MONEY, 
	@SCR_NDS10			MONEY, 
	@SCR_IC				MONEY, 
	@SCR_DELIVERY		MONEY, 	
	@SCR_TRAFFIC		MONEY, 
	@SCR_TOTAL_18		MONEY, 
	@SCR_NDS_18			MONEY, 
	@SCR_TOTAL_NDS		MONEY, 
	@SCR_INCOME			MONEY, 
	@SCR_DEBT			MONEY, 
	@SCR_SALDO			MONEY, 
	@SCR_PENALTY		MONEY, 
	@SCR_TOTAL			MONEY
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(
			SELECT *
			FROM Subhost.SubhostCalcReport
			WHERE SCR_ID_SUBHOST = @SH_ID
				AND SCR_ID_PERIOD = @PR_ID
		) 
	BEGIN
		RAISERROR('������ ��� ������.', 16, 1)
		RETURN
	END

	IF NOT EXISTS
		(
			SELECT *
			FROM Subhost.SubhostCalc 
			WHERE SHC_ID_SUBHOST = @SH_ID
				AND SHC_ID_PERIOD = @PR_ID
		)
	BEGIN
		RAISERROR('������ ��� �� ������������.', 16, 1)
		RETURN
	END

	DECLARE @TX_RATE DECIMAL(8,4)
	
	SELECT @TX_RATE = TX_TAX_RATE
	FROM dbo.PeriodTable
	CROSS APPLY dbo.TaxDefaultSelect(PR_DATE)
	WHERE PR_ID = @PR_ID

	INSERT INTO Subhost.SubhostCalcReport(
				SCR_ID_SUBHOST, SCR_ID_PERIOD, SCR_DELIVERY_SYS, SCR_SUPPORT, SCR_CNT, SCR_CNT_SPEC, SCR_DIU, SCR_PAPPER, 
				SCR_MARKET, SCR_STUDY, SCR_NDS10, 
				SCR_IC, SCR_IC_NDS,
				SCR_DELIVERY, SCR_TRAFFIC, SCR_TOTAL_18, SCR_NDS_18, SCR_TOTAL_NDS, 
				SCR_INCOME, SCR_DEBT, SCR_SALDO, SCR_PENALTY, SCR_TOTAL)
		SELECT 
				@SH_ID, @PR_ID, @SCR_DELIVERY_SYS, @SCR_SUPPORT, @SCR_CNT, @SCR_CNT_SPEC, @SCR_DIU, @SCR_PAPPER, 
				@SCR_MARKET, @SCR_STUDY, @SCR_NDS10, 
				@SCR_IC, ROUND(@SCR_IC * @TX_RATE, 2),
				@SCR_DELIVERY, @SCR_TRAFFIC, @SCR_TOTAL_18, @SCR_NDS_18, @SCR_TOTAL_NDS, 
				@SCR_INCOME, @SCR_DEBT, @SCR_SALDO, @SCR_PENALTY, @SCR_TOTAL

	UPDATE Subhost.SubhostCalc
	SET SHC_CLOSED = 1
	WHERE SHC_ID_SUBHOST = @SH_ID
		AND SHC_ID_PERIOD = @PR_ID
END
