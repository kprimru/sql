USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� ������� �����
               ������� �� ����������� (�� �
               ������ ������� ��� ����� �������),
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[SYSTEM_TRY_DELETE]
	@systemid SMALLINT
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

		-- ��������� 29.04.2009, �.������
		IF EXISTS(SELECT * FROM dbo.DistrTable WHERE DIS_ID_SYSTEM = @systemid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '���������� ������� �������, ��� ��� ���������� ' +
								+ '������������ ���� �������.' + CHAR(13)
			END

		IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_SYSTEM = @systemid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '���������� ������� �������, ��� ��� '
								+ '������� ������ � ������� ���.���� � ������ ��������.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_SYSTEM = @systemid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '���������� ������� �������, ��� ��� '
						+ '������� ������ � ����������� ����� ������ � ������ ��������.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.PriceSystemTable WHERE PS_ID_SYSTEM = @systemid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '���������� ������� �������, ��� ��� '
						+ '������� ������ � ������������ � ������ �������.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.PriceSystemHistoryTable WHERE PSH_ID_SYSTEM = @systemid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '���������� ������� �������, ��� ��� '
						+ '������� ������ � ������� ��� ������ �������.' + CHAR(13)
			END

		IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_SYSTEM = @systemid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �������, ��� ��� ��� ��� ����������������.'
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
GRANT EXECUTE ON [dbo].[SYSTEM_TRY_DELETE] TO rl_system_d;
GO