USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reg].[REG_PROTOCOL_OPERS]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT DISTINCT RPR_OPER
		FROM dbo.RegProtocol
		WHERE RPR_OPER NOT LIKE '"%'
			AND RPR_OPER NOT LIKE '�������� � ��������%'
			AND RPR_OPER NOT LIKE '������� email%'
			AND RPR_OPER NOT LIKE '������� �������%'
			AND RPR_OPER NOT LIKE '������� ������������� �������%'
			AND RPR_OPER NOT LIKE '������� �����������%'
			AND RPR_OPER NOT LIKE '������� ���. ��������%'
			AND RPR_OPER NOT LIKE '������� ����� ��������%'
			AND RPR_OPER NOT LIKE '������� ����. ���%'
			AND RPR_OPER NOT LIKE '�������� ����%'
			AND RPR_OPER NOT LIKE '������� ��%'
			AND RPR_OPER NOT LIKE '�������� �����%'
			AND RPR_OPER NOT LIKE '�������� �����������%'
			AND RPR_OPER NOT LIKE '�������� �����������%'
			AND RPR_OPER NOT LIKE '������� Yubikey%'
			AND RPR_OPER NOT LIKE '�������� Yubikey%'
			AND RPR_OPER NOT LIKE '�������� Yubikey%'
			AND RPR_OPER NOT LIKE '������ ����������� �������%'
			AND RPR_OPER NOT LIKE '�������� ����%'
			AND RPR_OPER NOT LIKE '����������� ���������� ���������� ��������%'
			AND RPR_OPER NOT LIKE '������� ������ ��%'
			AND RPR_OPER NOT LIKE '����������� ��������� ��%'
			AND RPR_OPER NOT LIKE '�������%'
			
		UNION
		
		SELECT '������� email'
			
		ORDER BY RPR_OPER
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
