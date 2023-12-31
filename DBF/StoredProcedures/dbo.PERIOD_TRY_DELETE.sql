USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� ������ �����
               ������� �� ����������� (�� ����
               �� ��������� �� ���� ������
               �� ������ ������),
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[PERIOD_TRY_DELETE]
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @res INT
		DECLARE @txt VARCHAR(MAX)

		SET @res = 0
		SET @txt = ''

		IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_PERIOD = @periodid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + '--'
		  END
		IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_PERIOD = @periodid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + CHAR(13) + '--'
		  END

		-- ��������� 29.04.2009, �.������
		IF EXISTS(SELECT * FROM dbo.ActDistrTable WHERE AD_ID_PERIOD = @periodid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt	+	'���������� ������� ������, ��� ��� ���������� ' +
								'���������� �� ���� ������ ����.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.BillTable WHERE BL_ID_PERIOD = @periodid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt +	'���������� ������� ������, ��� ��� ���������� ' +
								'���������� �� ���� ������ �����.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.InvoiceRowTable WHERE INR_ID_PERIOD = @periodid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt +	'���������� ������� ������, ��� ��� ���������� ' +
								'���������� �� ���� ������ �����-�������.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.IncomeDistrTable WHERE ID_ID_PERIOD = @periodid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt +	'���������� ������� ������, ��� ��� ���������� ' +
								'������� �� ������������� �� ���� ������.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.PriceSystemTable WHERE PS_ID_PERIOD = @periodid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt +	'���������� ������� ������, ��� ��� ���������� ' +
								'������������ �� ������������� �� ���� ������.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.VMIReportHistoryTable WHERE VRH_ID_PERIOD = @periodid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt +	'���������� ������� ������, ��� ��� ���������� ' +
								'����� ��� �� ���� ������.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.ClientHistoryTable WHERE CH_ID_PERIOD = @periodid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt +	'���������� ������� ������, ��� ��� ���������� ' +
								'������ � ������� ������� � ���� ��������.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.PriceSystemHistoryTable WHERE PSH_ID_PERIOD = @periodid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '���������� ������� ������, ��� ��� '
						+ '������� ������ � ������� ��� �� ������ ������.'
			END

		SELECT @res AS RES, @txt AS TXT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[PERIOD_TRY_DELETE] TO rl_period_d;
GO
