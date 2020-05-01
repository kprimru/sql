USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- �����:		  ������� �������
-- ���� ��������: 25.08.2008
-- ��������:	  ��������� ��� ��������.
--                �������� � ������������������ ����
--                ������ � ����������� ������ �������.
-- =============================================

ALTER PROCEDURE [dbo].[CONVERT_ADDRESS_TO_STRING]
	@clientid int
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

		  DECLARE @str varchar(250)
		  DECLARE @result int
		  DECLARE @addressstr varchar(500)
		  DECLARE @clientaddressid int

		  SET @result = 1

		  DECLARE @resultstr varchar(500)

		  DECLARE @code int

		  DECLARE @index varchar(10)
		  DECLARE @country varchar(50)
		  DECLARE @region varchar(50)
		  DECLARE @area varchar(50)
		  DECLARE @city varchar(100)
		  DECLARE @street varchar(100)
		  DECLARE @home varchar(50)

		  SET @index = ''
		  SET @country = ''
		  SET @region = ''
		  SET @area = ''
		  SET @city = ''
		  SET @street = ''
		  SET @home = ''

		  SELECT @str = CA_STR, @clientaddressid = CA_ID, @addressstr = CA_STR
		  FROM ClientAddressTable
		  WHERE CA_ID_TYPE = 1 AND CA_ID_CLIENT = @clientid

		  --���� ������ 6 �������� - ������

		  SET @str = LTRIM(RTRIM(@str))

		  IF dbo.IS_INDEX_CORRECT(LEFT(@str, 6)) = 0
			BEGIN
			  /*
				 ����� ������������ ����� ���� �� �����
				  1. <������>,<���������� �����>,<�����>,<���>
				  2. <������>,<������>,<�����>,<�����>,<���>
				  3. <������>,<������>,<�����>,<�����>,<���>
				  4. <������>,<������>,<�����>,<�����>,<�����>,<���>
				  5. <������>,<�����>,<���>
			  */
			  --�������� ������ 6 �������� � ������
			  SET @index = LEFT(@str, 6)
			  --� ������� �� ������ ������ � 7-� �������� - �������
			  SET @str = RIGHT(@str, LEN(@str) - 7)

			  SET @str = LTRIM(RTRIM(@str))

			  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_CITY_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
				BEGIN
					-- ������ 1
					-- ���������� ������ ����������� ������ (������ � ���������)
				  SET @city = LEFT(@str, CHARINDEX(',', @str) - 1)
				  -- � �������� ������ �� ����� ���. ������. ������ ������� ���� �����
				  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

				  SET @str = LTRIM(RTRIM(@str))

				  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_STREET_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
					BEGIN
						-- ��� �����
					  SET @street = LEFT(@str, CHARINDEX(',', @str) - 1)
					  -- �������� �� ������ �����
					  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

					  SET @str = LTRIM(RTRIM(@str))

					  -- ���, ��� �������� - ���.
					  SET @home = @str

					  SET @result = 0
					END --street
				END --sity
			  ELSE
				BEGIN
				  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_COUNTRY_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
					BEGIN
					  -- ������ 2

					  -- ���������� ������� �� �������
					  SET @country = LEFT(@str, CHARINDEX(',', @str) - 1)

					  -- �������� ������ �� ������
					  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))
					  SET @str = LTRIM(RTRIM(@str))

					  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_CITY_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
						BEGIN

						  -- ���������� ������ ����������� ������ (������ � ���������)
						  SET @city = LEFT(@str, CHARINDEX(',', @str) - 1)
						  -- � �������� ������ �� ����� ���. ������. ������ ������� ���� �����
						  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

						  SET @str = LTRIM(RTRIM(@str))

						  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_STREET_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
							BEGIN
							  -- ��� �����
							  SET @street = LEFT(@str, CHARINDEX(',', @str) - 1)
							  -- �������� �� ������ �����
							  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

							  SET @str = LTRIM(RTRIM(@str))

							  -- ���, ��� �������� - ���.
							  SET @home = @str

							  SET @result = 0
							END --street
						END --city
					END --country
				  ELSE
					BEGIN
					  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_REGION_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
						BEGIN
						  -- ���� 3 ���� 4 ������
						  -- ���������� ������ �������
						  SET @region = LEFT(@str, CHARINDEX(',', @str) - 1)
						  -- � �������� ������ �� ����� ���. ������. ������ ������� ���� �����
						  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

						  SET @str = LTRIM(RTRIM(@str))

						  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_AREA_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
							BEGIN
							  -- 4-� ������
							  -- ��� �����
							  SET @area = LEFT(@str, CHARINDEX(',', @str) - 1)
							  -- �������� �� ������ �����
							  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

							  SET @str = LTRIM(RTRIM(@str))

							  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_CITY_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
								BEGIN

								  -- ���������� ������ ����������� ������ (������ � ���������)
								SET @city = LEFT(@str, CHARINDEX(',', @str) - 1)
								-- � �������� ������ �� ����� ���. ������. ������ ������� ���� �����
								SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

								SET @str = LTRIM(RTRIM(@str))

								IF CHARINDEX(',', @str) <> 0 AND dbo.IS_STREET_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
								  BEGIN
									  -- ��� �����
									SET @street = LEFT(@str, CHARINDEX(',', @str) - 1)
									-- �������� �� ������ �����
									SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

									SET @str = LTRIM(RTRIM(@str))

									-- ���, ��� �������� - ���.
									SET @home = @str

									SET @result = 0
								  END --street
							  END --sity
							END --area
						  ELSE
							BEGIN
							  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_CITY_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
								BEGIN

								  -- ���������� ������ ����������� ������ (������ � ���������)
								SET @city = LEFT(@str, CHARINDEX(',', @str) - 1)
								-- � �������� ������ �� ����� ���. ������. ������ ������� ���� �����
								SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

								SET @str = LTRIM(RTRIM(@str))

								IF CHARINDEX(',', @str) <> 0 AND dbo.IS_STREET_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
								  BEGIN
									  -- ��� �����
									SET @street = LEFT(@str, CHARINDEX(',', @str) - 1)
									-- �������� �� ������ �����
									SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

									SET @str = LTRIM(RTRIM(@str))

									-- ���, ��� �������� - ���.
									SET @home = @str

									SET @result = 0
								  END --street
							  END --sity
							END
						END -- region
					  ELSE
						BEGIN
						  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_STREET_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
							BEGIN
								-- ��� �����
								SET @street = LEFT(@str, CHARINDEX(',', @str) - 1)
								-- �������� �� ������ �����
								SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

								SET @str = LTRIM(RTRIM(@str))

								-- ���� ����� �� ������, �� �������, ��� �����������
								SET @city = '�.�����������'
								-- ���, ��� �������� - ���.
								SET @home = @str

								SET @result = 0
							END
						END
					END
				  END
			END -- index
		  ELSE
			BEGIN
			  /*
				 ���� ������ �� ������ - ��� ������� ����. ������ ����� ���������, �� ���������� �����������
				 ����������� �������� ��� �������
				  1. <���������� �����>,<�����>,<���>
				  2. <�����>,<���>
				 �� ������ ������, ������� �� ��������� ����� �����������.
			  */

			  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_CITY_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
				BEGIN
					-- ������ 1
					-- ���������� ������ ����������� ������ (������ � ���������)
				  SET @city = LEFT(@str, CHARINDEX(',', @str) - 1)
				  -- � �������� ������ �� ����� ���. ������. ������ ������� ���� �����
				  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

				  SET @str = LTRIM(RTRIM(@str))

				  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_STREET_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
					BEGIN
						-- ��� �����
					  SET @street = LEFT(@str, CHARINDEX(',', @str) - 1)
					  -- �������� �� ������ �����
					  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

					  SET @str = LTRIM(RTRIM(@str))

					  -- ���, ��� �������� - ���.
					  SET @home = @str

					  SET @result = 0
					END --street
				END --sity
			  ELSE
				BEGIN
				  IF CHARINDEX(',', @str) <> 0 AND dbo.IS_STREET_CORRECT(LEFT(@str, CHARINDEX(',', @str) - 1)) = 0
					BEGIN
					  -- ������ 2
						-- ��� �����
					  SET @street = LEFT(@str, CHARINDEX(',', @str) - 1)
					  -- �������� �� ������ �����
					  SET @str = RIGHT(@str, LEN(@str) - CHARINDEX(',', @str))

					  SET @str = LTRIM(RTRIM(@str))

					  SET @city = '�.�����������'
					  -- ���, ��� �������� - ���.
					  SET @home = @str

					  SET @result = 0
					END --street
				END
			END


		  SET @resultstr = CONVERT(varchar, @result) + '' +
						   '"' + @index + '"' +
						   '"' + @country + '"' +
						   '"' + @region + '"' +
						   '"' + @area + '"' +
						   '"' + @city + '"' +
						   '"' + @street + '"' +
						   '"' + @home + '"'


		  DECLARE @streetid int

		  SET @streetid = 0

		  DECLARE @cityname varchar(100)
		  DECLARE @cityprefix varchar(50)
		  DECLARE @streetname varchar(100)
		  DECLARE @streetprefix varchar(50)


		  IF CHARINDEX('.', @city) <> 0
			BEGIN
			  SET @cityprefix = LEFT(@city, CHARINDEX('.', @city))
			  -- ���� �����, ������ ������ ����� ���� �. �� ����� ������������ - �������

			  SET @cityname = LTRIM(RTRIM(RIGHT(@city, LEN(@city) - CHARINDEX('.', @city))))
			END
		  ELSE
			BEGIN
			  SET @cityprefix = ''
			  SET @cityname = @city
			END

		  IF LEN(@cityprefix) > 5 OR LEN(@cityname) < 5
			BEGIN
			  -- ���-�� ��������������
			  SET @cityprefix= ''
			  SET @cityname = ''
			END

		  IF CHARINDEX('.', @street) <> 0
			BEGIN
			  -- ���� �����, ������ ������ ����� ���� �. �� ����� ������������ - �������
			  SET @streetprefix = LEFT(@street, CHARINDEX('.', @street))
			  -- ���� �����, ������ ������ ����� ���� �. �� ����� ������������ - �������

			  SET @streetname = LTRIM(RTRIM(RIGHT(@street, LEN(@street) - CHARINDEX('.', @street))))
			END
		  ELSE
			BEGIN
			  SET @streetprefix = ''
			  SET @streetname = @street
			END

		  IF LEN(@streetprefix) > 5 OR LEN(@streetname) < 5
			BEGIN
			  SET @streetprefix = ''
			  SET @streetname = ''
			END

		  DECLARE @street_temp_name varchar(100)

		  SELECT @street_temp_name = ST_NAME, @streetid = ST_ID
		  FROM ClientAddressTable INNER JOIN
			   StreetTable ON ClientAddressTable.CA_ID_STREET = StreetTable.ST_ID
		  WHERE CA_ID_CLIENT = @clientid AND CA_ID_TYPE = 2

		  IF UPPER(@street_temp_name) <> UPPER(@streetname)
			BEGIN
			  SET @streetid = 0

			  SELECT @streetid = ST_ID
			  FROM StreetTable a INNER JOIN
				   CityTable b ON a.ST_ID_CITY = b.CT_ID
			  WHERE ST_NAME = @streetname AND CT_NAME = @cityname
			END

		  IF @streetid <> 0
			EXEC CLIENT_ADDRESS_EDIT @clientaddressid, @streetid, @index, @home, 1, @addressstr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END
