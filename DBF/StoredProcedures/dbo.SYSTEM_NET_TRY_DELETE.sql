USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 23.09.2008
��������:	  ���������� 0, ���� ��� ����
               � ��������� ����� ����� �������
               (�� ���� �� ��������� �� ����
               ������ � ���� ������),
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[SYSTEM_NET_TRY_DELETE]
	@systemnetid SMALLINT
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
		IF EXISTS(SELECT * FROM dbo.DistrFinancingTable WHERE DF_ID_NET = @systemnetid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '���������� ������� ��� ����, ��� ��� ������� ���������� ��������� � ���� �����. '
			END

		IF EXISTS(SELECT * FROM dbo.SystemNetCountTable WHERE SNC_ID_SN = @systemnetid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + CHAR(13) + '���������� ������� ��� ����, ��� ��� � ��� ������� ���������� ������� �������. '
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
GRANT EXECUTE ON [dbo].[SYSTEM_NET_TRY_DELETE] TO rl_system_net_d;
GO
