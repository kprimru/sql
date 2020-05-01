USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� ����� � ��������� 
               ����� ����� ������� �� ����������� 
               (�� ��� �� ��������� �� ���� �����), 
               -1 � ��������� ������
*/

CREATE PROCEDURE [dbo].[STREET_TRY_DELETE] 
	@streetid INT
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
		IF EXISTS(SELECT * FROM dbo.ClientAddressTable WHERE CA_ID_STREET = @streetid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �����, ��� ��� ��� ������� � ������� ��������. '
		  END

		IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_ID_STREET = @streetid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �����, ��� ��� ��� ������� � ������� ������������� �����������.'
		  END
		IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_S_ID_STREET	 = @streetid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �����, ��� ��� ��� ������� � ������� ������������� �����������.'
		  END

		IF EXISTS(SELECT * FROM dbo.TOAddressTable WHERE TA_ID_STREET	 = @streetid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + '���������� ������� �����, ��� ��� ��� ������� � ������� ����� ������������.'
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
