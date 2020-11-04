USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[DepoList@Select From File]
	@Data			Xml,
	@HideUnchanged	Bit = 1
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	DECLARE @DepoFile Table
	(
		[Ric]				SmallInt,
		[Code]				Int,
		[Priority]			Int,
		[Name]				VarChar(256),
		[Inn]				VarChar(20),
		[RegionAndAddress]	VarChar(256),
		[Person1FIO]		VarChar(128),
		[Person1Phone]		VarChar(128),
		[Result]			VarChar(50),
		[Status]			VarChar(50),
		[AlienInn]			VarChar(50),
		[DepoDate]			SmallDateTime,
		[DepoExpireDate]	SmallDateTime,
		[Rival]				VarChar(50),
		Primary Key Clustered([Code])
	);

	INSERT INTO Client.CompanyDepoFile([Depo])
	VALUES(@Data);

	INSERT INTO @DepoFile
	SELECT *
	FROM [Client].[DepoList@Parse](@Data);

	SELECT
		[Checked] = Cast(CASE WHEN [Action] NOT IN ('N', 'E') THEN 1 ELSE 0 END AS Bit),
		[ActionDescription] =
								CASE [Action]
									WHEN 'I' THEN '����������� ��������� � ����'
									WHEN 'R' THEN '����� �� ��������� � ����'
									WHEN 'D' THEN '������� �� ������ ����'
									WHEN 'E' THEN '������! ����� ���� �� ���������������'
									WHEN 'X' THEN '��������! ���������� ���� ��������� ���������'
									WHEN 'N' THEN '������ �� ����������'
								END,
		*
	FROM
	(
		SELECT
			F.[Code],
			[Name] = IsNull(F.[Name], D.[Depo:Name]),
			F.[DepoDate],
			F.[DepoExpireDate],
			[Number] = IsNull(F.[Code], D.[Number]),
			D.[Id],
			D.[Company_Id],
			D.[StatusCode],
			D.[StatusName],
			[Action] =
						CASE
							-- ������������� ������
							WHEN F.[Code] IS NOT NULL AND D.[Number] IS NOT NULL AND D.[StatusCode] != 'ACTIVE' THEN 'I'
							-- ����� �� ��������� � ����
							WHEN F.[Code] IS NULL AND D.[StatusCode] != 'ACTIVE' THEN 'R'
							-- �������� ��������� �� ������
							WHEN F.[Code] IS NULL AND D.[StatusCode] = 'ACTIVE' THEN 'D'
							-- ������, ����� �������� ��� � ������ ����������������
							WHEN D.[Number] IS NULL THEN 'E'
							-- ���������� ���� ��������� ���������
							WHEN D.[ExpireDate] != F.[DepoExpireDate] THEN 'X'
							-- ����� - ������ �� ����������. ��� ���� ����������� ��������
							ELSE 'N'
						END
		FROM @DepoFile F
		FULL JOIN
		(
			SELECT
				D.[Id],
				D.[Company_Id],
				D.[Number],
				D.[Depo:Name],
				D.[DateFrom],
				D.[DateTo],
				D.[ExpireDate],
				[StatusCode] = S.[Code],
				[StatusName] = S.[Name]
			FROM Client.CompanyDepo D
			INNER JOIN [Client].[Depo->Statuses] S ON D.[Status_Id] = S.[Id]
			WHERE	D.Status = 1
				AND S.[Code] NOT IN ('REFUSED', 'STAGE', 'NEW')
		) AS D ON F.[Code] = D.[Number]
	) D
	WHERE @HideUnchanged = 0 OR @HideUnchanged = 1 AND D.[Action] != 'N'
	ORDER BY D.[Action], D.[Number]
	OPTION(RECOMPILE)
END

GO
GRANT EXECUTE ON [Client].[DepoList@Select From File] TO rl_depo_file_process;
GO