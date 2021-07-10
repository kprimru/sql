USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 05.11.2008
��������:	  ���������� 0, � ������ ����
               �������� ���������� ����� �������
               (��� �� ������� �� � ��������������),
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[MARKET_AREA_TRY_DELETE]
	@marketareaid INT
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

		SELECT @res AS RES, @txt AS TXT

		-- ��������� 30.04.2009, �.������
		IF EXISTS(SELECT * FROM dbo.SubhostCityTable WHERE SC_ID_MARKET_AREA = @marketareaid)
			BEGIN
				SET @res = 1
				SET @txt = @txt	+	'���������� ������� �������� ����������, ��� ��� ��� ������� ' +
									'� ����� ��� ����������� ����������. '
			END
		--

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[MARKET_AREA_TRY_DELETE] TO rl_market_area_d;
GO