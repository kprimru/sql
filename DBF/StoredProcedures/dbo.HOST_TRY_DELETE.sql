USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  ���������� 0, ���� ����
               ����� �������,
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[HOST_TRY_DELETE]
	@hostid SMALLINT
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

		IF EXISTS(SELECT * FROM dbo.SystemTable WHERE SYS_ID_HOST = @hostid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ���� ������ � ����� ��� ���������� ������. ' +
							  '�������� ����������, ���� ��������� ���� ����� ������ ���� ' +
							  '�� � ����� �������.'
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
GRANT EXECUTE ON [dbo].[HOST_TRY_DELETE] TO rl_host_d;
GO
