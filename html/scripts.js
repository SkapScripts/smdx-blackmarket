document.addEventListener('DOMContentLoaded', () => {
    const uiElement = document.getElementById('blackmarket-ui');
    const productsElement = document.getElementById('products');
    const closeButton = document.getElementById('close-btn');

    window.addEventListener('message', (event) => {
        const { action, data } = event.data;

        if (action === 'openUI') {
            uiElement.classList.remove('hidden');
            productsElement.innerHTML = '';

            data.products.forEach(product => {
                const productDiv = document.createElement('div');
                productDiv.textContent = `${product.name} - $${product.price}`;
                productDiv.onclick = () => {
                    fetch(`https://${GetParentResourceName()}/buyItem`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ item: {
                            name: product.name,
                            itemID: product.itemID,
                            price: product.price,
                            event: product.event
                        }})
                    });
                };                             
                productsElement.appendChild(productDiv);
            });
        } else if (action === 'closeUI') {
            uiElement.classList.add('hidden');
        }
    });

    closeButton.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST'
        }).then(() => {
            uiElement.classList.add('hidden');
        });
    });
});
