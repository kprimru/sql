USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  ���������� 0, ���� ����������� �
               ��������� ����� ����� ������� ��
               ������, -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[DISTR_TRY_DELETE]
	@distrid INT
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

		IF EXISTS(SELECT * FROM dbo.ClientDistrTable WHERE CD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������ ����������� � ������-�� �������. �������� ����������,'
								+ '���� ��������� ����������� ����������� �������.'
								+ CHAR(13)
			END

		-- ��������� 30.04.2009, �.������
		IF EXISTS(SELECT * FROM dbo.BillDistrTable WHERE BD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������� ����, � ������� ������ ������ �����������. �������� ����������,'
								+ '���� ��������� ����������� ������ � �����.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.ContractDistrTable WHERE COD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������� �������, � ������� ������ ������ �����������. �������� ����������,'
								+ '���� ��������� ����������� ������ � ��������.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.ActDistrTable WHERE AD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������� ���, � ������� ������ ������ �����������. �������� ����������,'
								+ '���� ��������� ����������� ������ � ����.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.IncomeDistrTable WHERE ID_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������� ������, � ������� ������ ������ �����������. �������� ����������,'
								+ '���� ��������� ����������� ������ � �������.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.InvoiceRowTable WHERE INR_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������� ����-�������, � ������� ������ ������ �����������. �������� ����������,'
								+ '���� ��������� ����������� ������ � ����-�������.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.PrimaryPayTable WHERE PRP_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������� ��������� ������, � ������� ������ ������ �����������. �������� ����������,'
								+ '���� ��������� ����������� ������ � ��������� ������.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.TODistrTable WHERE TD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������ ����������� ������ � �����-�� ��. �������� ����������,'
								+ '���� ��������� ����������� ����������� ��.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.SaldoTable WHERE SL_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '�������� ����������, ��� ��� ������ ����������� ������ � ������ � ������.'
			END

		--


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
GRANT EXECUTE ON [dbo].[DISTR_TRY_DELETE] TO rl_distr_d;
GO