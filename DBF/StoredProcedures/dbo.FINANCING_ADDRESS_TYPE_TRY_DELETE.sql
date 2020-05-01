USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			������� ������� 
���� ��������:	3 July 2009
��������:		���������� 0, ���� ��� ������ � ���. ��������� 
				� ��������� ����� ����� ������� �� 
				�����������, 
				-1 � ��������� ������
*/
CREATE PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_TRY_DELETE] 
	@fatid SMALLINT
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

	/*
		IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_FIN = @financingid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + '������ ��� �������������� ������ � ������ ��� ���������� ��������. ' + 
							  '�������� ����������, ���� ��������� ��� �������������� ����� ������ ���� ' +
							  '�� � ������ �������.'
		  END 
	*/

		SELECT @res AS RES, @txt AS TXT


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
