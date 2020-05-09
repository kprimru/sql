USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� �������������
               ����������� � ��������� ����� �����
               ������� �� ����������� (��� ��
               ������� �� � ������ �������),
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[ORGANIZATION_TRY_DELETE]
	@organizationid SMALLINT
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

		IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������ ����������� ������� � ������ ��� ���������� ��������. ' +
								  '�������� ����������, ���� ��������� ����������� ����� ������� ���� ' +
								  '�� � ������ �������.'
			END

		-- ��������� 29.04.2009, �.������
		IF EXISTS(SELECT * FROM dbo.ActTable WHERE ACT_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt	+	'���������� ������� �����������, ��� ��� ���������� ' +
									'���������� �� ��� ����������� ����.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.BillTable WHERE BL_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt	+	'���������� ������� �����������, ��� ��� ���������� ' +
									'���������� �� ��� ����������� �����.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.IncomeTable WHERE IN_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt	+	'���������� ������� �����������, ��� ��� ���������� ' +
									'����������� �� ��� ����������� �������.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.InvoiceSaleTable WHERE INS_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt	+	'���������� ������� �����������, ��� ��� ���������� ' +
									'���������� �� ��� ����������� �����-�������.' + CHAR(13)
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
GRANT EXECUTE ON [dbo].[ORGANIZATION_TRY_DELETE] TO rl_organization_d;
GO