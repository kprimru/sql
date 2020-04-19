USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[CALC_CHECK]
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

		/*
		�������� ������������:
		1. ����� � �� ����� ������� ���������
		2. ����� � ��������� ��� �������� ������� �����
		3. ����� � ������� ��� ������ ���
		4. ����� � ����������� ������ ������ ��� ������ ������� (���� �� ��� ���, ������� ������������� �� ����������)
		*/

		SELECT COUR_NAME AS [��������], '�� ������ ��� ��' AS [��� ��������]
		FROM dbo.CourierTable
		WHERE COUR_ACTIVE = 1
			AND COUR_ID_TYPE IS NULL
			
		UNION ALL
			
		SELECT COUR_NAME, '�� ������ ������� �����'
		FROM dbo.CourierTable
		WHERE COUR_ACTIVE = 1
			AND COUR_ID_TYPE = 2
			AND COUR_ID_CITY IS NULL

		UNION ALL
			
		SELECT CL_PSEDO, '�� ������ ��� �������'
		FROM 
			dbo.ClientTable
			INNER JOIN dbo.TOTable ON TO_ID_CLIENT = CL_ID
			INNER JOIN dbo.CourierTable ON COUR_ID = TO_ID_COUR
		WHERE CL_ID_TYPE IS NULL AND COUR_ID_TYPE = 2

		UNION ALL

		SELECT CT_NAME, '�� ������ ������� ���������� ����� ��� ����������� ������'
		FROM 
			(
				SELECT DISTINCT ST_ID_CITY
				FROM 
					dbo.TOTable
					INNER JOIN dbo.CourierTable ON COUR_ID = TO_ID_COUR
					INNER JOIN dbo.TOAddressTable ON TA_ID_TO = TO_ID
					INNER JOIN dbo.StreetTable ON ST_ID = TA_ID_STREET
				WHERE COUR_ID_TYPE = 2
			) AS o_O
			INNER JOIN dbo.CityTable ON ST_ID_CITY = CT_ID
		WHERE CT_ID_BASE IS NULL
		ORDER BY 2, 1
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
