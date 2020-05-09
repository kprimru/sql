USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- �����:		  ������� �������
-- ���� ��������: 25.08.2008
-- ��������:	  ���������� 0, ���� ���������� �����
--                ����� ������� �� ����������� (��
--                ���� ����� � �� ���� ���� �� �������
--                �� ������ ���������� �����),
--                -1 � ��������� ������
-- =============================================

ALTER PROCEDURE [dbo].[CITY_TRY_DELETE]
  @cityid int

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

		IF EXISTS(SELECT * FROM dbo.StreetTable WHERE ST_ID_CITY = @cityid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������ ���������� ����� ������ � ����� ��� ���������� ����. ' +
								  '�������� ����������, ���� ��������� ���������� ����� ����� ������ ���� ' +
								  '�� � ����� �����.' + CHAR(13)
			END

		IF EXISTS(SELECT * FROM dbo.BankTable WHERE BA_ID_CITY = @cityid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '������ ���������� ����� ������ � ������ ��� ���������� ������. ' +
							  '�������� ����������, ���� ��������� ���������� ����� ����� ������ ���� ' +
							  '�� � ������ �����.' + CHAR(13)
			END

		-- ��������� 4.05.2009
		IF EXISTS(SELECT * FROM dbo.SubhostCityTable WHERE SC_ID_CITY = @cityid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '�������� ����������, ��� ��� ������ ���������� �����'
								+ '������ � ������ ������� ���������.'
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
GRANT EXECUTE ON [dbo].[CITY_TRY_DELETE] TO rl_city_d;
GO