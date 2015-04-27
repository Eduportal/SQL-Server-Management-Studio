DECLARE	@ListID UNIQUEIDENTIFIER

SELECT	@ListID = tp_ID
FROM	dbo.Lists WITH(NOLOCK) 
WHERE	tp_Title = 'DBLookup'


SELECT	*
FROM	dbo.UserData
WHERE	tp_ListId = @ListID



