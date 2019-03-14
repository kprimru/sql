USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
�����:			������� �������/������ ��������
���� ��������:  	
��������:		
*/
CREATE PROCEDURE [dbo].[ACT_CALC]
	-- ������ ���������� ���������
	@clientid INT,
	@periodid SMALLINT,
	@distrid INT,
	@date SMALLDATETIME,
	@oldactid INT,
	@newact BIT = 0,
	@coid INT = NULL,
	@courid INT = NULL,
	@to	BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID INT

	DECLARE @actid INT
	
	IF @oldactid IS NULL
		SELECT TOP 1 @actid = a.ACT_ID
		FROM 			
			dbo.ActTable a INNER JOIN 
			dbo.ActContractView b ON a.ACT_ID = b.ACT_ID
		WHERE ACT_ID_CLIENT = @clientid 
			AND CO_ID = @coid
			AND	ACT_ID_INVOICE IS NULL	
		ORDER BY a.ACT_ID DESC
		
	ELSE
		SET @actid = @oldactid
			
	IF @newact = 1
		SET @actid = NULL

	IF @actid IS NULL
		BEGIN
			INSERT INTO dbo.ActTable (ACT_DATE, ACT_ID_CLIENT, ACT_ID_ORG, ACT_ID_COUR, ACT_TO, ACT_ID_PAYER)
				SELECT @date, @clientid, CL_ID_ORG, @courid, @to, CL_ID_PAYER
					FROM dbo.ClientTable 
					WHERE CL_ID = @clientid
			SELECT @actid = SCOPE_IDENTITY()
		END

	INSERT INTO dbo.ActDistrTable
		(
			AD_ID_ACT, AD_ID_DISTR, AD_ID_PERIOD,
			AD_ID_TAX, AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE,
			AD_PAYED_PRICE
		)
		SELECT 
			@actid, BD_ID_DISTR, @periodid,
			BD_ID_TAX, BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE,
			(				
				ISNULL((
					SELECT SUM(ID_PRICE)
					FROM 
						dbo.IncomeDistrTable INNER JOIN
						dbo.IncomeTable ON IN_ID = ID_ID_INCOME INNER JOIN
						dbo.DistrView ON DIS_ID = ID_ID_DISTR INNER JOIN
						dbo.SaleObjectTable a ON SO_ID = SYS_ID_SO
					WHERE IN_ID_CLIENT = BL_ID_CLIENT
						AND ID_ID_PERIOD = BL_ID_PERIOD
						AND ID_ID_DISTR = BD_ID_DISTR
						--AND ID_PREPAY = 0
						AND a.SO_ID = b.SYS_ID_SO
					), 0)
			) AS AD_PAYED_RICE
		FROM 
			dbo.BillDistrTable INNER JOIN
			dbo.BillTable ON BL_ID = BD_ID_BILL INNER JOIN
			dbo.DistrDocumentView c ON DIS_ID = BD_ID_DISTR INNER JOIN
			dbo.DistrView b ON c.DIS_ID = b.DIS_ID
		WHERE	BL_ID_PERIOD = @periodid
			AND BL_ID_CLIENT = @clientid
			AND	BD_ID_DISTR = @distrid
			AND DOC_PSEDO = 'ACT'
			AND DD_PRINT = 1
			
	SELECT @ID = SCOPE_IDENTITY()
	DECLARE @TXT VARCHAR(MAX)
	
	EXEC dbo.ACT_PROTOCOL_DETAIL @ID, @TXT OUTPUT
	
	EXEC dbo.FINANCING_PROTOCOL_ADD 'ACT', '��������� ������ ����', @TXT, @clientid, @actid
END