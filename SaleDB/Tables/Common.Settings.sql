USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Settings]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_USER]        UniqueIdentifier          NULL,
        [DEFAULT_RUS]    Bit                   NOT NULL,
        [SEARCH_EXT]     Bit                   NOT NULL,
        [MULTY_SEARCH]   Bit                   NOT NULL,
        [WARNING_TIME]   SmallInt              NOT NULL,
        [FONT_SIZE]      SmallInt              NOT NULL,
        [OFFER_PATH]     NVarChar(1024)            NULL,
        [LAST]           DateTime              NOT NULL,
        CONSTRAINT [PK_Settings] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Settings_Users] FOREIGN KEY  ([ID_USER]) REFERENCES [Security].[Users] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_LAST] ON [Common].[Settings] ([LAST] ASC);
GO
