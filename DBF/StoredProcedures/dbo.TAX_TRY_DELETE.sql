USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������, ������ ��������
���� ��������: 27.01.2009
��������:	  ���������� 0, ���� ����� �������
               �����,
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[TAX_TRY_DELETE]
	@taxid SMALLINT
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

		-- ��������� 28.04.2009, �.������
		IF EXISTS(SELECT * FROM dbo.PrimaryPayTable WHERE PRP_ID_TAX = @taxid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �����, ��� ��� ���������� ������ � ��������� ������ � ���� �������. '
		  END

		IF EXISTS(SELECT * FROM dbo.InvoiceRowTable WHERE INR_ID_TAX = @taxid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + CHAR(13) + '���������� ������� �����, ��� ��� ���������� ����-������� � ���� �������. '
		  END

		IF EXISTS(SELECT * FROM dbo.BillDistrTable WHERE BD_ID_TAX = @taxid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + CHAR(13) + '���������� ������� �����, ��� ��� ���������� ����� � ���� �������. '
		  END

		IF EXISTS(SELECT * FROM dbo.SaleObjectTable WHERE SO_ID_TAX = @taxid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + CHAR(13) + '���������� ������� �����, ��� ��� ���������� ������� ������ � ���� �������. '
		  END

		IF EXISTS(SELECT * FROM dbo.ActDistrTable WHERE AD_ID_TAX = @taxid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + CHAR(13) + '���������� ������� �����, ��� ��� ���������� ���� � ���� �������. '
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
GRANT EXECUTE ON [dbo].[TAX_TRY_DELETE] TO rl_tax_d;
GO