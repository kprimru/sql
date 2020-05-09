USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CompanyDepo@StageSortIndex]
	@Id			UniqueIdentifier,
	@Direction	VarChar(10)	= NULL,
	@Number		Int			= NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Status_STAGE		SmallInt,
		@CurNumber			Int;

	BEGIN TRY
		IF @Direction IS NULL AND @Number IS NULL
			RaisError('Abstract Error: @Direction IS NULL AND @Number IS NULL', 16, 1);

		IF @Direction IS NOT NULL AND @Number IS NOT NULL
			RaisError('Abstract Error: @Direction IS NOT NULL AND @Number IS NOT NULL', 16, 1);

		IF @Direction IS NOT NULL AND @Direction NOT IN ('UP', 'DOWN')
			RaisError('Abstract Error: @Direction NOT IN "UP", "DOWN", @Direction = %s', 16, 1, @Direction);

		SET @Status_STAGE = (SELECT TOP (1) [Id] FROM [Client].[Depo->Statuses] WHERE [Code] = 'STAGE');
		SET @CurNumber = (SELECT TOP (1) [SortIndex] FROM [Client].[CompanyDepo] WHERE [Id] = @Id);

		IF @Direction IS NOT NULL
			SET @Number = CASE @Direction WHEN 'UP' THEN @CurNumber - 1 WHEN 'DOWN' THEN @CurNumber + 1 ELSE NULL END;

		IF @Number IS NOT NULL BEGIN
			UPDATE D
			SET [SortIndex] = I.[NewSortIndex]
			FROM [Client].[CompanyDepo] AS D
			INNER JOIN
			(
				SELECT
					[Id],
					[NewSortIndex] = Row_Number() Over(ORDER BY R.[NewSortIndex])
				FROM [Client].[CompanyDepo] AS ND
				CROSS APPLY
				(
					SELECT
						[NewSortIndex] =
									CASE
										-- � ������������� ������ ������ ������
										WHEN [Id] = @Id THEN @Number
										-- ���� ������ ����������� �����, �� ������� ����� @Number � @CurNumber ����������� �������
										WHEN @CurNumber > @Number AND [SortIndex] >= @Number AND [SortIndex] <= @CurNumber THEN [SortIndex] + 1
										-- ���� �������� ���� � ������ ���� ����������� - ����������� �� 1
										WHEN @CurNumber < @Number AND [SortIndex] <= @Number AND [SortIndex] >= @CurNumber THEN [SortIndex] - 1
										-- ����� �� ������
										ELSE [SortIndex]
									END
				) AS R
				WHERE ND.[Status_Id] = @Status_STAGE
					AND ND.STATUS = 1
			) AS I ON D.[Id] = I.[Id]
			WHERE D.[Status_Id] = @Status_STAGE
				AND D.STATUS = 1
		END ELSE BEGIN
			RaisError('Abstract Error: @Direction IS NULL AND @Number IS NULL', 16, 1);
		END;
	END TRY
	BEGIN CATCH
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Client].[CompanyDepo@StageSortIndex] TO rl_depo_stage_filter;
GO